@tool
extends FunctionBoxShape
class_name FunctionBoxCircleShape

@export var interpolate_from: FunctionBoxCircleShape = null;
@export var radius: float = 10;
@export var position: Vector2 = Vector2.ZERO;

func push_to_shape(
	shape: FunctionBoxCollisionShape2D, 
	moved_distance: Vector2, 
	interpolate: bool, 
	transform_matrix: Vector4 = Vector4(1,0,0,1)
) -> void:
	var transformed_pos: Vector2 = FrameMathUtil.apply_transform(self.position, transform_matrix);
	if self.interpolate_from == null || !interpolate:
		shape.push_circle(transformed_pos, self.radius);
	else:
		shape.push_capsule(
			FrameMathUtil.apply_transform(self.interpolate_from.position, transform_matrix) - moved_distance, 
			transformed_pos, 
			self.radius
		);
