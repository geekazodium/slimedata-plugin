@tool
extends EditorOperationExecutor
class_name DeleteOperationExecutor

func get_operation_name() -> String:
	return "Delete";

func execute(editing_provider: FrameDataProviderTool) -> void:
	EditorInterface.get_inspector().edit(null);
	for layer: EditableFunctionBoxLayer in editing_provider.get_layers():
		for shape in layer.get_selected_shapes():
			if shape.shape_src.key != shape.key:
				push_error("something is wrong with the internal state");
			editing_provider.remove_shape(shape.shape_src, false);
		layer.clear_selected();
	editing_provider.push_current_frame_to_shapes();
	self.end_operation();

func request_cancel() -> void:
	return;

func process(delta: float) -> void:
	pass;
