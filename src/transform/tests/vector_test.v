module main

import transform

fn test_normalize_vector_with_zero_x() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 0, y: 1 })

	assert normalized_vector.x.eq_epsilon(0)
	assert normalized_vector.y.eq_epsilon(1)
}

fn test_normalize_vector_with_zero_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 1, y: 0 })

	assert normalized_vector.x.eq_epsilon(1)
	assert normalized_vector.y.eq_epsilon(0)
}

fn test_normalize_vector_with_zero_x_and_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 0, y: 0 })

	assert normalized_vector.x.eq_epsilon(0)
	assert normalized_vector.y.eq_epsilon(0)
}

fn test_normalize_vector_with_positive_x_and_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 1, y: 1 })

	assert normalized_vector.x.eq_epsilon(0.7071067811865475)
	assert normalized_vector.y.eq_epsilon(0.7071067811865475)
}

fn test_normalize_vector_with_negative_x_and_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: -1, y: -1 })

	assert normalized_vector.x.eq_epsilon(-0.7071067811865475)
	assert normalized_vector.y.eq_epsilon(-0.7071067811865475)
}

fn test_normalize_vector_with_positive_x_and_negative_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 1, y: -1 })

	assert normalized_vector.x.eq_epsilon(0.7071067811865475)
	assert normalized_vector.y.eq_epsilon(-0.7071067811865475)
}

fn test_normalize_vector_with_negative_x_and_positive_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: -1, y: 1 })

	assert normalized_vector.x.eq_epsilon(-0.7071067811865475)
	assert normalized_vector.y.eq_epsilon(0.7071067811865475)
}

fn test_normalize_vector_with_positive_x_and_y_greater_than_one() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 2, y: 2 })

	assert normalized_vector.x.eq_epsilon(0.7071067811865475)
	assert normalized_vector.y.eq_epsilon(0.7071067811865475)
}

fn test_normalize_vector_with_one_x_and_ten_y() {
	normalized_vector := transform.normalize_vector(transform.Vector{ x: 1, y: 10 })

	assert normalized_vector.x.eq_epsilon(0.09950371902099892)
	assert normalized_vector.y.eq_epsilon(0.9950371902099892)
}
