module ecs

import artemkakun.trnsfrm2d as transform

pub struct NewWorld {
mut:
	id_counter                             u64
	entity_id_to_archetype                 map[u64]ArchetypeRecord
	hashed_components_ids_to_archetype_map map[string]&Archetype
	component_id_to_archetypes_map         map[string]map[u64]int
}

struct ArchetypeRecord {
	row_id    int
	archetype &Archetype
}

pub struct Archetype {
	id             u64
	components_ids []string
mut:
	components [][]NewComponent
}

pub interface NewComponent {
	component_id string
}

pub fn create_entity(mut world NewWorld, components []NewComponent) u64 {
	mut sorted_components_ids := components.map(it.component_id)
	sorted_components_ids.sort()

	hashed_components_ids := sorted_components_ids.join('')

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

fn register_archetype(mut world NewWorld, components_ids []string) &Archetype {
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

	hashed_components_ids := components_ids.join('')

	world.hashed_components_ids_to_archetype_map[hashed_components_ids] = archetype

	return archetype
}

pub fn entity_has_component(world NewWorld, entity_id u64, component_id string) bool {
	archetype_record := world.entity_id_to_archetype[entity_id]
	archetype := archetype_record.archetype

	return archetype.id in world.component_id_to_archetypes_map[component_id]
}

pub struct NewPosition {
	transform.Position
	component_id string = 'position'
}
