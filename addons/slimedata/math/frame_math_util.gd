class_name FrameMathUtil

static func apply_transform(position: Vector2, transform_matrix: Vector4) -> Vector2:
	return Vector2(
		transform_matrix.x * position.x + transform_matrix.y * position.y,
		transform_matrix.z * position.x + transform_matrix.w * position.y
	);
