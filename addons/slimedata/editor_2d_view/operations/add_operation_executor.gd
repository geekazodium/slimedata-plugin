@tool
extends EditorOperationExecutor
class_name AddOperationExecutor

@export var editing_provider: FrameDataProviderTool;

func get_operation_name() -> String:
	return "Add Shape";

func execute() -> void:
	var shape: FunctionBoxCircleShape = FunctionBoxCircleShape.new();
	shape.position = Vector2.from_angle(randf() * PI * 2) * randf_range(0,100);
	self.editing_provider.add_shape(shape);
