module ecs

fn test_register_archetype() {
	mut world := NewWorld{}
	new_archetype := register_archetype(mut world, [typeof[NewPosition]().idx])

	assert new_archetype.id == 0
	assert new_archetype.components_ids == [typeof[NewPosition]().idx]
	assert new_archetype.components == [][]NewComponent{}
}

fn test_create_entity() {
	mut world := NewWorld{}
	new_archetype := register_archetype(mut world, [typeof[NewPosition]().idx])
	new_entity_id := create_entity(mut world, [NewPosition{ x: 1, y: 2 }])

	assert new_entity_id == 1
	assert new_archetype.components[0][0] is NewPosition

	test := new_archetype.components[0][0]

	if test is NewPosition {
		assert test.x == 1
		assert test.y == 2
	}
}

fn test_entity_has_component() {
	mut world := NewWorld{}
	new_entity_id := create_entity(mut world, [NewPosition{ x: 1, y: 2 }])

	assert entity_has_component[NewPosition](world, new_entity_id)!
}

fn test_entity_get_component() {
	mut world := NewWorld{}
	new_entity_id := create_entity(mut world, [NewPosition{ x: 1, y: 2 }])

	component := get_component[NewPosition](world, new_entity_id)!

	if component is NewPosition {
		assert component.x == 1
		assert component.y == 2
	} else {
		assert false
	}
}

fn test_get_component_from_2_entities() {
	mut world := NewWorld{}
	new_entity_id_1 := create_entity(mut world, [NewPosition{ x: 1, y: 2 }])
	new_entity_id_2 := create_entity(mut world, [NewPosition{ x: 3, y: 4 }])

	component_1 := get_component[NewPosition](world, new_entity_id_1)!

	if component_1 is NewPosition {
		assert component_1.x == 1
		assert component_1.y == 2
	} else {
		assert false
	}

	component_2 := get_component[NewPosition](world, new_entity_id_2)!

	if component_2 is NewPosition {
		assert component_2.x == 3
		assert component_2.y == 4
	} else {
		assert false
	}
}
