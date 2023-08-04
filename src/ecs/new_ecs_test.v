module ecs

fn test_register_archetype() {
	mut world := NewWorld{}
	new_archetype := register_archetype(mut world, [NewPosition{}.component_id])

	assert new_archetype.id == 0
	assert new_archetype.components_ids == [NewPosition{}.component_id]
	assert new_archetype.components == [][]NewComponent{}
}

fn test_create_entity() {
	mut world := NewWorld{}
	new_archetype := register_archetype(mut world, [NewPosition{}.component_id])
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

	assert entity_has_component(world, new_entity_id, NewPosition{}.component_id)
}
