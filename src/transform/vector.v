module transform

import math

// Vector Describes a 2D vector.
// It is used for representing direction or velocity, but not position (use Position for that).
// The precision may be changed to f32 in the future.
pub struct Vector {
pub:
	x f64
	y f64
}

fn (first_vector Vector) == (second_vector Vector) bool {
	return first_vector.x.eq_epsilon(second_vector.x) && first_vector.y.eq_epsilon(second_vector.y)
}

// normalize_vector Normalizes the input vector.
//
// Example:
// ```v
// normalize_vector(Vector{1.0, 1.0}) // returns Vector{0.707106782, 0.707106782}
// ```
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

	magnitude := calculate_vector_magnitude(vector_to_normalize)

	return Vector{x / magnitude, y / magnitude}
}

fn is_vector_normalized(vector_to_check Vector) bool {
	return calculate_vector_magnitude(vector_to_check).eq_epsilon(1)
}

fn calculate_vector_magnitude(vector Vector) f64 {
	x := vector.x
	y := vector.y

	return math.sqrt(x * x + y * y)
}
