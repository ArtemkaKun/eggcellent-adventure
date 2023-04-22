module main

import scale_factor
import tests_helpers

fn test_calculate_scale_factor_reference_resolution_height_is_zero_returns_error() {
	test_function := get_test_function(0, 1, 1, 1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.reference_resolution_height_smaller_than_zero_error)
}

fn test_calculate_scale_factor_reference_resolution_height_is_negative_returns_error() {
	test_function := get_test_function(-1, 1, 1, 1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.reference_resolution_height_smaller_than_zero_error)
}

fn test_calculate_scale_factor_reference_resolution_width_is_zero_returns_error() {
	test_function := get_test_function(1, 0, 1, 1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.reference_resolution_width_smaller_than_zero_error)
}

fn test_calculate_scale_factor_reference_resolution_width_is_negative_returns_error() {
	test_function := get_test_function(1, -1, 1, 1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.reference_resolution_width_smaller_than_zero_error)
}

fn test_calculate_scale_factor_target_resolution_height_is_zero_returns_error() {
	test_function := get_test_function(1, 1, 0, 1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.target_resolution_height_smaller_than_zero_error)
}

fn test_calculate_scale_factor_target_resolution_height_is_negative_returns_error() {
	test_function := get_test_function(1, 1, -1, 1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.target_resolution_height_smaller_than_zero_error)
}

fn test_calculate_scale_factor_target_resolution_width_is_zero_returns_error() {
	test_function := get_test_function(1, 1, 1, 0)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.target_resolution_width_smaller_than_zero_error)
}

fn test_calculate_scale_factor_target_resolution_width_is_negative_returns_error() {
	test_function := get_test_function(1, 1, 1, -1)
	tests_helpers.expect_error_from_test_function(test_function, scale_factor.target_resolution_width_smaller_than_zero_error)
}

fn test_calculate_scale_factor_reference_and_target_resolutions_aspect_ratios_are_same_width_scaling_factor_is_smaller_returns_width_scaling_factor() {
	test_function := get_test_function(540, 960, 1080, 1920)

	assert test_function()!.eq_epsilon(2)
}

fn test_calculate_scale_factor_reference_and_target_resolutions_aspect_ratios_are_same_height_scaling_factor_is_smaller_returns_height_scaling_factor() {
	test_function := get_test_function(960, 540, 1920, 1080)

	assert test_function()!.eq_epsilon(2)
}

fn test_calculate_scale_factor_reference_aspect_ratio_is_bigger_than_target_aspect_ratio_returns_width_scaling_factor() {
	test_function := get_test_function(1, 2, 1, 1)

	assert test_function()!.eq_epsilon(0.5)
}

fn test_calculate_scale_factor_reference_aspect_ratio_is_smaller_than_target_aspect_ratio_returns_height_scaling_factor() {
	test_function := get_test_function(1, 1, 1, 2)

	assert test_function()!.eq_epsilon(1)
}

fn get_test_function(reference_resolution_height int, reference_resolution_width int, target_resolution_height int, target_resolution_width int) fn () !f64 {
	return fn [reference_resolution_height, reference_resolution_width, target_resolution_height, target_resolution_width] () !f64 {
		return scale_factor.calculate_scale_factor(reference_resolution_height, reference_resolution_width,
			target_resolution_height, target_resolution_width)
	}
}
