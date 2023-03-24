module transform

import math

// Vector Describes a vector in 2D space.
// Should be used to describe a direction or velocity, but not a position (use Position for that).
// f64 precision is used for now, but it may be changed to f32 in the future.
pub struct Vector {
	x f64
	y f64
}

// normalize_vector Normalizes a vector.
pub fn normalize_vector(vector_to_normalize Vector) Vector {
	x := vector_to_normalize.x
	y := vector_to_normalize.y

	magnitude := math.sqrt(x * x + y * y)

	return Vector{x / magnitude, y / magnitude}
}
