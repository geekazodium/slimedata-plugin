@tool
extends FunctionBoxShape
class_name FunctionBoxCircleShape

@export var interpolate_from: FunctionBoxCircleShape = null;
@export var radius: float = 10;
@export var position: Vector2 = Vector2.ZERO;

func push_to_shape(shape: FunctionBoxCollisionShape2D, moved_distance: Vector2, interpolate: bool) -> void:
	if self.interpolate_from == null || !interpolate:
		shape.push_circle(self.position, self.radius);
	else:
		shape.push_capsule(self.interpolate_from.position - moved_distance, self.position, self.radius);
