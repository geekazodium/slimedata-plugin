@tool
extends FunctionBoxShape
class_name FunctionBoxCircleShape

@export var interpolate_from: FunctionBoxCircleShape = null;
@export var radius: float = 10;
@export var position: Vector2 = Vector2.ZERO;

func push_to_shape(shape: FunctionBoxCollisionShape2D):
	if self.interpolate_from == null:
		shape.push_circle(self.position, self.radius);
	else:
		shape.push_capsule(self.interpolate_from.position, self.position, self.radius);
