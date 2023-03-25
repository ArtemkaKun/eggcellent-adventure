module transform

import math

// Vector Describes a vector in 2D space.
// Should be used to describe a direction or velocity, but not a position (use Position for that).
// f64 precision is used for now, but it may be changed to f32 in the future.
pub struct Vector {
pub:
	x f64
	y f64
}

// normalize_vector Normalizes a vector.
pub fn normalize_vector(vector_to_normalize Vector) Vector {
	x := vector_to_normalize.x
	y := vector_to_normalize.y

	if x.eq_epsilon(0.0) && y.eq_epsilon(0.0) {
		return vector_to_normalize
	}

	if x.eq_epsilon(0.0) {
		return Vector{x, y / math.abs(y)}
	}

	if y.eq_epsilon(0.0) {
		return Vector{x / math.abs(x), y}
	}

	magnitude := math.sqrt(x * x + y * y)

	return Vector{x / magnitude, y / magnitude}
}
