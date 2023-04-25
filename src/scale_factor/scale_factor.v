// This code implements integer scale factor calculations, that can be used to scale pixel art images.

module scale_factor

import math

pub const (
	reference_resolution_height_smaller_than_zero_error = 'reference_resolution_height must be greater than zero'
	reference_resolution_width_smaller_than_zero_error  = 'reference_resolution_width must be greater than zero'
	target_resolution_height_smaller_than_zero_error    = 'target_resolution_height must be greater than zero'
	target_resolution_width_smaller_than_zero_error     = 'target_resolution_width must be greater than zero'
)

// calculate_integer_scale_factor Calculates the integer scale factor for a given reference and target resolutions.
// The scale factor can't be smaller than 1.
//
// ATTENTION!⚠ reference_resolution_height and reference_resolution_width must be greater than zero.
// ATTENTION!⚠ target_resolution_height and target_resolution_width must be greater than zero.
//
// Example:
// ```v
// scale_factor := scale_factor.calculate_integer_scale_factor(240, 320, 480, 640) // scale_factor = 2
// ```
pub fn calculate_integer_scale_factor(reference_resolution_height int, reference_resolution_width int, target_resolution_height int, target_resolution_width int) !int {
	if reference_resolution_height <= 0 {
		return error(scale_factor.reference_resolution_height_smaller_than_zero_error)
	}

	if reference_resolution_width <= 0 {
		return error(scale_factor.reference_resolution_width_smaller_than_zero_error)
	}

	if target_resolution_height <= 0 {
		return error(scale_factor.target_resolution_height_smaller_than_zero_error)
	}

	if target_resolution_width <= 0 {
		return error(scale_factor.target_resolution_width_smaller_than_zero_error)
	}

	reference_aspect_ratio := f64(reference_resolution_width) / reference_resolution_height
	target_aspect_ratio := f64(target_resolution_width) / target_resolution_height

	width_scale_factor := f64(target_resolution_width) / reference_resolution_width
	height_scale_factor := f64(target_resolution_height) / reference_resolution_height

	mut scale_factor := 1.0

	if reference_aspect_ratio.eq_epsilon(target_aspect_ratio) {
		scale_factor = math.min[f64](width_scale_factor, height_scale_factor)
	}

	if reference_aspect_ratio > target_aspect_ratio {
		scale_factor = width_scale_factor
	} else {
		scale_factor = height_scale_factor
	}

	integer_scale_factor := int(math.round(scale_factor))

	return math.max[int](integer_scale_factor, 1)
}
