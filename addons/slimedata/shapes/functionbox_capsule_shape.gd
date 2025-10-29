@tool
extends FunctionBoxShape
class_name FunctionBoxCapsuleShape

@export var radius: float = 10;
@export var position1: Vector2 = Vector2.ZERO;
@export var position2: Vector2 = Vector2.UP;

func push_to_shape(
	shape: FunctionBoxCollisionShape2D, 
	moved_distance: Vector2, 
	interpolate: bool, 
	transform_matrix: Vector4 = Vector4(1,0,0,1)
) -> void:
	shape.push_capsule(
		FrameMathUtil.apply_transform(self.position1, transform_matrix),
		FrameMathUtil.apply_transform(self.position2, transform_matrix),
		self.radius
	);
