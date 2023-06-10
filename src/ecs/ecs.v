module ecs

// World represents the world.
// It contains a collection of all entities and a counter for unique entity IDs.
[heap]
pub struct World {
mut:
	entities_id_counter u64
	entities            []Entity
}

// Entity represents a game object within the world.
// It has a unique ID and a collection of components that define its behavior.
pub struct Entity {
pub:
	id u64
mut:
	components []Component
}

// Component is an interface for components.
// Components define various aspects of an entity's behavior.
pub interface Component {}

// register_entity adds a new entity with the specified components to the world.
// It assigns a unique ID to the new entity, incrementing the world's entity ID counter.
pub fn register_entity(mut world World, components []Component) {
	world.entities << Entity{
		id: world.entities_id_counter
		components: components
	}

	world.entities_id_counter += 1
}

// execute_system_with_three_components applies a system function to each entity that has components of type A, B, and D in the given world.
// The system function must take three parameters, all of which are references to components of type A, B, and D respectively.
pub fn execute_system_with_three_components[A, B, D](world World, system fn (&A, &B, &D)) {
	query := query_for_three_components[A, B, D]
	entities := get_entities_with_query(world, query)

	for entity in entities {
		// NOTE: continue will never be reached here, since the query function guarantees that the entity has both components.
		a_component := get_entity_component[A](entity) or { continue }
		b_component := get_entity_component[B](entity) or { continue }
		d_component := get_entity_component[D](entity) or { continue }

		system(a_component, b_component, d_component)
	}
}

// query_for_three_components is a query function that checks if an entity has components of type A, B, and D.
pub fn query_for_three_components[A, B, D](entity Entity) bool {
	return query_for_two_components[A, B](entity) && check_if_entity_has_component[D](entity)
}

// execute_system_with_two_components applies a system function to each entity that has both components of type A and B in the given world.
// The system function must take two parameters, both of which are references to components of type A and B respectively.
pub fn execute_system_with_two_components[A, B](world World, system fn (&A, &B)) {
	query := query_for_two_components[A, B]
	entities := get_entities_with_query(world, query)

	for entity in entities {
		// NOTE: continue will never be reached here, since the query function guarantees that the entity has both components.
		a_component := get_entity_component[A](entity) or { continue }
		b_component := get_entity_component[B](entity) or { continue }

		system(a_component, b_component)
	}
}

// query_for_two_components is a query function that checks if an entity has components of type A and B.
pub fn query_for_two_components[A, B](entity Entity) bool {
	return check_if_entity_has_component[A](entity) && check_if_entity_has_component[B](entity)
}

// check_if_entity_has_component checks if the given entity has a component of type T.
// It returns true if a component of type T is found, and false otherwise.
pub fn check_if_entity_has_component[T](entity Entity) bool {
	get_entity_component[T](entity) or { return false }

	return true
}

// get_entity_component retrieves the first component of type T from the given entity's components.
// If no component of type T is found, it returns an error.
pub fn get_entity_component[T](entity Entity) !&T {
	for component in entity.components {
		if component is T {
			return component
		}
	}

	return error('Entity with ID ${entity.id} does not have a component of type ${T.name}')
}

// get_entities_with_query applies a provided query function to filter entities within the given world.
// The query function must take an Entity as input and return a boolean indicating whether the Entity matches the query.
pub fn get_entities_with_query(world World, query fn (Entity) bool) []Entity {
	return world.entities.filter(query(it))
}

// remove_entity removes an entity identified by entity_id from the given world.
// If the entity doesn't exist, it returns an error.
pub fn remove_entity(mut world World, entity_id u64) ! {
	mut index_to_remove := -1

	for index, entity in world.entities {
		if entity.id == entity_id {
			index_to_remove = index
			break
		}
	}

	if index_to_remove == -1 {
		return error('Entity with ID ${entity_id} not found in world')
	}

	world.entities.delete(index_to_remove)
}

// remove_component removes a component of type T from an entity identified by entity_id in the given ECS world.
// If the entity or the component doesn't exist, it returns an error.
pub fn remove_component[T](mut ecs_world World, entity_id u64) ! {
	for _, mut entity in ecs_world.entities {
		if entity.id == entity_id {
			component := get_entity_component[T](entity) or {
				return error('Entity with ID ${entity_id} does not have a component of type ${T.name}')
			}

			component_index := entity.components.index(*component)

			if component_index == -1 {
				return error('Component of type ${T.name} not found in entity with ID ${entity_id}')
			}

			entity.components.delete(component_index)

			return
		}
	}

	return error('Entity with ID ${entity_id} not found in ECS world')
}
