@tool
extends EditorOperationExecutor
class_name AddOperationExecutor

func get_operation_name() -> String:
	return "Add Shape";

func execute(editing_provider: FrameDataProviderTool) -> void:
	var shape: FunctionBoxCircleShape = FunctionBoxCircleShape.new();
	shape.position = Vector2.from_angle(randf() * PI * 2) * randf_range(0,100);
	editing_provider.add_shape(shape);
	self.end_operation();

func request_cancel() -> void:
	return;

func process(delta: float) -> void:
	pass
