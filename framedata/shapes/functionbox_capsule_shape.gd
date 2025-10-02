@tool
extends FunctionBoxShape
class_name FunctionBoxCapsuleShape

@export var radius: float = 10;
@export var position1: Vector2 = Vector2.ZERO;
@export var position2: Vector2 = Vector2.UP;

func push_to_shape(shape: FunctionBoxCollisionShape2D):
	shape.push_capsule(self.position1,self.position2,self.radius);
