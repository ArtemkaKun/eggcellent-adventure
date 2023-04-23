// This code implements integer scale factor calculations, that can be used to scale pixel art images.

module scale_factor

import math

pub const (
	reference_resolution_height_smaller_than_zero_error = 'reference_resolution_height must be greater than zero'
	reference_resolution_width_smaller_than_zero_error  = 'reference_resolution_width must be greater than zero'
	target_resolution_height_smaller_than_zero_error    = 'target_resolution_height must be greater than zero'
	target_resolution_width_smaller_than_zero_error     = 'target_resolution_width must be greater than zero'
)

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

	mut scale_factor := 1.0

	if reference_aspect_ratio.eq_epsilon(target_aspect_ratio) {
		scale_factor = math.min[f64](f64(target_resolution_width) / reference_resolution_width,
			f64(target_resolution_height) / reference_resolution_height)
	}

	if reference_aspect_ratio > target_aspect_ratio {
		scale_factor = f64(target_resolution_width) / reference_resolution_width
	}

	if target_aspect_ratio > reference_aspect_ratio {
		scale_factor = f64(target_resolution_height) / reference_resolution_height
	}

	integer_scale_factor := int(math.round(scale_factor))

	return math.max[int](integer_scale_factor, 1)
}
