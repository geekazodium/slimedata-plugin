@tool
@abstract
extends Resource
class_name FunctionBoxShape

@export var data: Resource;
@export var key: int;
@export var priority: int;

@abstract
func push_to_shape(shape: FunctionBoxCollisionShape2D, moved_distance: Vector2, interpolate: bool) -> void;

func push_properties(shape: FunctionBoxCollisionShape2D) -> void:
	shape.key = self.key;
	shape.priority = self.priority;
	shape.shape_src = self;
