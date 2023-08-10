module ecs

// World represents the world.
// It contains all entities, archetypes, and their relations with components.
[heap]
pub struct World {
mut:
	id_counter                             u64
	entity_id_to_archetype                 map[u64]ArchetypeRecord
	hashed_components_ids_to_archetype_map map[u64]&Archetype
	component_id_to_archetypes_map         map[int]map[u64]int
}

struct ArchetypeRecord {
	row_id    int
	archetype &Archetype
}

struct Archetype {
	id             u64
	components_ids []int
mut:
	components   [][]Component
	entities_ids []u64
}

// Component is an interface for components.
// Components define various aspects of an entity's behavior.
pub interface Component {}

// create_entity create a new relation - unique entity ID to archetype (created if needed) -
// and stores provided components in this archetype.
// Then, returns the entity ID.
pub fn create_entity(mut world World, components []Component) u64 {
	mut sorted_components_ids := components.map(it.type_idx())
	sorted_components_ids.sort()

	mut hashed_components_ids := u64(sorted_components_ids.len)

	for id in sorted_components_ids {
		hashed_components_ids = hashed_components_ids * 31 + u64(id)
	}

	mut archetype := world.hashed_components_ids_to_archetype_map[hashed_components_ids] or {
		register_archetype(mut world, sorted_components_ids)
	}

	mut sorted_components := []Component{}

	for sorted_component_id in sorted_components_ids {
		for component in components {
			if component.type_idx() == sorted_component_id {
				sorted_components << component
				break
			}
		}
	}

	archetype.components << sorted_components
	entity_id := world.id_counter
	archetype.entities_ids << entity_id
	world.id_counter += 1

	world.entity_id_to_archetype[entity_id] = ArchetypeRecord{
		row_id: archetype.components.len - 1
		archetype: archetype
	}

	return entity_id
}

fn register_archetype(mut world World, components_ids []int) &Archetype {
	archetype := &Archetype{
		id: world.id_counter
		components_ids: components_ids
	}

	world.id_counter += 1

	for index, component_id in components_ids {
		if component_id in world.component_id_to_archetypes_map {
			world.component_id_to_archetypes_map[component_id][archetype.id] = index
		} else {
			world.component_id_to_archetypes_map[component_id] = {
				archetype.id: index
			}
		}
	}

	mut hashed_components_ids := u64(components_ids.len)

	for id in components_ids {
		hashed_components_ids = hashed_components_ids * 31 + u64(id)
	}

	world.hashed_components_ids_to_archetype_map[hashed_components_ids] = archetype

	return archetype
}

// entity_has_component checks if an entity has a component of type T.
// Returns error if the type T is not a ECS component.
pub fn entity_has_component[T](world World, entity_id u64) !bool {
	$if T is Component {
		archetype_record := world.entity_id_to_archetype[entity_id] or {
			return error("Entity ${entity_id} doesn't exist")
		}

		return archetype_has_component(world, archetype_record.archetype, T.idx)
	} $else {
		return error('Type ${T.name} is not a ECS component')
	}
}

// get_component returns a reference to a component of type T for the given entity.
// Returns error if the type T is not a ECS component or the entity doesn't have a component of type T.
pub fn get_component[T](world World, entity_id u64) !&T {
	$if T is Component {
		record := world.entity_id_to_archetype[entity_id] or {
			return error("Entity ${entity_id} doesn't exist")
		}

		archetype := record.archetype

		if archetype_has_component(world, archetype, T.idx) == false {
			return error("Entity ${entity_id} doesn't have ${T.name} component")
		}

		column_id := world.component_id_to_archetypes_map[T.idx][archetype.id]
		return_component := archetype.components[record.row_id][column_id]

		if return_component is T {
			return return_component
		} else {
			return error("Entity ${entity_id} doesn't have ${T.name} component")
		}
	} $else {
		return error('Type ${T.name} is not a ECS component')
	}
}

fn archetype_has_component(world World, archetype Archetype, component_id int) bool {
	return archetype.id in world.component_id_to_archetypes_map[component_id]
}

// execute_system_with_two_components applies a system function to each entity that has both components of type A and B in the given world.
// The system function must take two parameters, both of which are references to components of type A and B respectively.
pub fn execute_system_with_two_components[A, B](world World, system fn (&A, &B)) {
	for entity_id, _ in world.entity_id_to_archetype {
		a_component := get_component[A](world, entity_id) or { continue }
		b_component := get_component[B](world, entity_id) or { continue }
		system(a_component, b_component)
	}
}

// query_for_two_components is a query function that checks if an entity has components of type A and B.
pub fn query_for_two_components[A, B](world World, entity_id u64) !bool {
	return query_for_component[A](world, entity_id)! && query_for_component[B](world, entity_id)!
}

// query_for_component is a query function that checks if an entity has a component of type T.
pub fn query_for_component[T](world World, entity_id u64) !bool {
	return entity_has_component[T](world, entity_id)!
}

// get_entities_ids_with_query applies a provided query function to filter entities within the given world.
// The query function must take an entity id as input and return a boolean indicating whether the Entity matches the query.
pub fn get_entities_ids_with_query(world World, query fn (World, u64) !bool) ![]u64 {
	mut matched_entities := []u64{}

	for entity_id, _ in world.entity_id_to_archetype {
		if query(world, entity_id) or { continue } {
			matched_entities << entity_id
		}
	}

	return matched_entities
}

// remove_entity removes an entity identified by entity_id from the given world.
// If the entity doesn't exist, it returns an error.
pub fn remove_entity(mut world World, entity_id u64) ! {
	archetype_record_to_remove_from := world.entity_id_to_archetype[entity_id] or {
		return error("Entity ${entity_id} doesn't exist")
	}

	mut archetype := archetype_record_to_remove_from.archetype
	row_id := archetype_record_to_remove_from.row_id

	archetype.components.delete(row_id)

	entity_archetype_index := archetype.entities_ids.index(entity_id)
	archetype.entities_ids.delete(entity_archetype_index)

	if archetype.entities_ids.len > 0 {
		for index in entity_archetype_index .. archetype.entities_ids.len {
			old_archetype := world.entity_id_to_archetype[archetype.entities_ids[index]] or {
				return error("Entity ${entity_id} doesn't exist")
			}

			world.entity_id_to_archetype[archetype.entities_ids[index]] = ArchetypeRecord{
				...old_archetype
				row_id: old_archetype.row_id - 1
			}
		}
	}

	world.entity_id_to_archetype.delete(entity_id)
}

// remove_component removes a component of type T from an entity identified by entity_id in the given ECS world.
// If the entity or the component doesn't exist, it returns an error.
pub fn remove_component[T](mut world World, entity_id u64) ! {
	$if T is Component {
		archetype_record := world.entity_id_to_archetype[entity_id] or {
			return error("Entity ${entity_id} doesn't exist")
		}

		if entity_has_component[T](world, entity_id)! == false {
			return error("Entity ${entity_id} doesn't have ${T.name} component")
		}

		mut archetype := archetype_record.archetype
		mut new_component_ids := archetype.components_ids.clone()
		new_component_ids.delete(new_component_ids.index(T.idx))

		new_component_ids.sort()

		mut hashed_components_ids := u64(new_component_ids.len)

		for id in new_component_ids {
			hashed_components_ids = hashed_components_ids * 31 + u64(id)
		}

		mut new_archetype := world.hashed_components_ids_to_archetype_map[hashed_components_ids] or {
			register_archetype(mut world, new_component_ids)
		}

		component_id_in_old_archetype := world.component_id_to_archetypes_map[T.idx][archetype.id]
		mut new_components_array := archetype.components[archetype_record.row_id].clone()
		new_components_array.delete(component_id_in_old_archetype)

		mut sorted_components := []Component{}

		for sorted_component_id in new_component_ids {
			for component in new_components_array {
				if component.type_idx() == sorted_component_id {
					sorted_components << component
					break
				}
			}
		}

		new_archetype.components << sorted_components
		new_archetype.entities_ids << entity_id

		world.entity_id_to_archetype[entity_id] = ArchetypeRecord{
			row_id: new_archetype.components.len - 1
			archetype: new_archetype
		}

		archetype.components.delete(archetype_record.row_id)

		entity_archetype_index := archetype.entities_ids.index(entity_id)
		archetype.entities_ids.delete(entity_archetype_index)

		if archetype.entities_ids.len > 0 {
			for index in entity_archetype_index .. archetype.entities_ids.len {
				old_archetype := world.entity_id_to_archetype[archetype.entities_ids[index]] or {
					return error("Entity ${entity_id} doesn't exist")
				}

				world.entity_id_to_archetype[archetype.entities_ids[index]] = ArchetypeRecord{
					...old_archetype
					row_id: old_archetype.row_id - 1
				}
			}
		}
	} $else {
		return error('Type ${T.name} is not a ECS component')
	}
}
