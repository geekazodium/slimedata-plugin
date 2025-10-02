@tool
extends Resource
class_name FunctionBoxShape

@export var data: Resource;
@export var key: PackedByteArray;
@export var priority: int;

@warning_ignore("unused_parameter")
func push_to_shape(shape: FunctionBoxCollisionShape2D):
	push_error("push to shape method not defined!");
