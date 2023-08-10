module ecs

fn test_register_archetype() {
	mut world := World{}
	new_archetype := register_archetype(mut world, [typeof[Position]().idx])

	assert new_archetype.id == 0
	assert new_archetype.components_ids == [typeof[Position]().idx]
	assert new_archetype.components == [][]Component{}
}

fn test_create_entity() {
	mut world := World{}
	new_archetype := register_archetype(mut world, [typeof[Position]().idx])
	new_entity_id := create_entity(mut world, [Position{ x: 1, y: 2 }])

	assert new_entity_id == 1
	assert new_archetype.components[0][0] is Position

	test := new_archetype.components[0][0]

	if test is Position {
		assert test.x == 1
		assert test.y == 2
	}
}

fn test_entity_has_component() {
	mut world := World{}
	new_entity_id := create_entity(mut world, [Position{ x: 1, y: 2 }])

	assert entity_has_component[Position](world, new_entity_id)!
}

fn test_entity_get_component() {
	mut world := World{}
	new_entity_id := create_entity(mut world, [Position{ x: 1, y: 2 }])

	component := get_component[Position](world, new_entity_id)!

	assert component.x == 1
	assert component.y == 2
}

fn test_get_component_from_2_entities() {
	mut world := World{}
	new_entity_id_1 := create_entity(mut world, [Position{ x: 1, y: 2 }])
	new_entity_id_2 := create_entity(mut world, [Position{ x: 3, y: 4 }])

	component_1 := get_component[Position](world, new_entity_id_1)!

	assert component_1.x == 1
	assert component_1.y == 2

	component_2 := get_component[Position](world, new_entity_id_2)!

	assert component_2.x == 3
	assert component_2.y == 4
}
