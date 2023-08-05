module ecs

import artemkakun.trnsfrm2d as transform

pub struct NewWorld {
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

pub struct Archetype {
	id             u64
	components_ids []int
mut:
	components [][]NewComponent
}

pub interface NewComponent {}

pub fn create_entity(mut world NewWorld, components []NewComponent) u64 {
	mut sorted_components_ids := components.map(it.type_idx())
	sorted_components_ids.sort()

	mut hashed_components_ids := u64(sorted_components_ids.len)

	for id in sorted_components_ids {
		hashed_components_ids = hashed_components_ids * 31 + u64(id)
	}

	mut archetype := world.hashed_components_ids_to_archetype_map[hashed_components_ids] or {
		register_archetype(mut world, sorted_components_ids)
	}

	archetype.components << components

	entity_id := world.id_counter
	world.id_counter += 1

	world.entity_id_to_archetype[entity_id] = ArchetypeRecord{
		row_id: archetype.components.len - 1
		archetype: archetype
	}

	return entity_id
}

fn register_archetype(mut world NewWorld, components_ids []int) &Archetype {
	archetype := &Archetype{
		id: world.id_counter
		components_ids: components_ids
		components: [][]NewComponent{}
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

pub fn entity_has_component[T](world NewWorld, entity_id u64) !bool {
	$if T is NewComponent {
		archetype_record := world.entity_id_to_archetype[entity_id]

		return archetype_has_component(world, archetype_record.archetype, T.idx)
	} $else {
		return error('Type ${T.name} is not a ECS component')
	}
}

pub fn get_component[T](world NewWorld, entity_id u64) !&NewComponent {
	$if T is NewComponent {
		record := world.entity_id_to_archetype[entity_id]
		archetype := record.archetype

		if archetype_has_component(world, archetype, T.idx) == false {
			return error("Entity ${entity_id} doesn't have ${T.name} component")
		}

		column_id := world.component_id_to_archetypes_map[T.idx][archetype.id]

		return &archetype.components[record.row_id][column_id]
	} $else {
		return error('Type ${T.name} is not a ECS component')
	}
}

fn archetype_has_component(world NewWorld, archetype Archetype, component_id int) bool {
	return archetype.id in world.component_id_to_archetypes_map[component_id]
}

pub struct NewPosition {
	transform.Position
}

fn interface_hack() NewComponent {
	return NewPosition{}
}
