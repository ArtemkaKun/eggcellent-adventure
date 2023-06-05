module ecs

pub struct Entity {
pub:
	id u64
mut:
	components []IComponent
}

pub interface IComponent {}

pub struct World {
mut:
	id_counter u64
	entities   []Entity
}

pub fn register_entity(mut world World, components []IComponent) {
	world.entities << Entity{
		id: world.id_counter
		components: components
	}

	world.id_counter += 1
}

pub fn get_entities_with_two_components[A, B](world World) ![]Entity {
	entities_that_has_a := world.entities.filter(check_if_entity_has_component[A](it))

	return entities_that_has_a.filter(check_if_entity_has_component[B](it))
}

pub fn check_if_entity_has_component[T](entity Entity) bool {
	for component in entity.components {
		if component is T {
			return true
		}
	}

	return false
}

pub fn get_component[T](entity Entity) !&T {
	for component in entity.components {
		if component is T {
			return component
		}
	}

	return error('Entity does not have component')
}

pub fn execute_system_with_two_components[A, B](world World, system fn (&A, &B)) ! {
	entities := get_entities_with_two_components[A, B](world)!

	for entity in entities {
		system(get_component[A](entity)!, get_component[B](entity)!)
	}
}

pub fn execute_system_with_three_components[A, B, D](world World, system fn (&A, &B, &D)) ! {
	entities := get_entities_with_three_components[A, B, D](world)!

	for entity in entities {
		system(get_component[A](entity)!, get_component[B](entity)!, get_component[D](entity)!)
	}
}

pub fn get_entities_with_three_components[A, B, D](world World) ![]Entity {
	entities_that_has_a := world.entities.filter(check_if_entity_has_component[A](it))
	entities_that_has_a_and_b := entities_that_has_a.filter(check_if_entity_has_component[B](it))

	return entities_that_has_a_and_b.filter(check_if_entity_has_component[D](it))
}

pub fn remove_entity(mut world World, entity_id u64) {
	mut index_to_remove := -1

	for index, entity in world.entities {
		if entity.id == entity_id {
			index_to_remove = index
			break
		}
	}

	if index_to_remove == -1 {
		return
	}

	world.entities.delete(index_to_remove)
}

pub fn remove_component[T](mut ecs_world World, entity_id u64) ! {
	for _, mut entity in ecs_world.entities {
		if entity.id == entity_id {
			entity.components.delete(entity.components.index(*get_component[T](entity)!))
		}
	}
}
