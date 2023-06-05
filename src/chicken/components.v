module chicken

import ecs

pub struct GravityAffection {
pub:
	gravity_force f64
}

pub struct IsControlledByPlayerTag {}

// HACK: This function is a workaround to a limitation in V's interface implementation.
// In V, a struct automatically implements an interface if it satisfies all of the interface's methods and fields.
// However, for our empty interface for ECS components, no struct can satisfy it as there are no methods or fields to implement.
// This function tackles this issue by returning a struct as an interface type, tricking the compiler into believing the struct implements the interface.
// This approach, while unorthodox, allows for cleaner code as it avoids the need for an explicit base struct to be embedded in every component struct.
// To use a component struct in ECS, it should be placed within a similar function.
// The function uses an array to accommodate multiple components, thereby preventing code duplication.
// This hack should be removed when interface for ECS component will have methods or fields.
fn component_interface_hack() []ecs.IComponent {
	return [GravityAffection{}, IsControlledByPlayerTag{}]
}
