@tool
extends EditorOperationExecutor
class_name DeleteOperationExecutor

@export var editing_provider: FrameDataProviderTool;

func get_operation_name() -> String:
	return "Delete";

func execute() -> void:
	for layer: EditableFunctionBoxLayer in self.editing_provider.get_layers():
		for shape in layer._selected_shapes:
			if shape.shape_src.key != shape.key:
				push_error("something is wrong with the internal state");
			self.editing_provider.remove_shape(shape.shape_src, false);
		layer.clear_selected();
	self.editing_provider.push_current_frame_to_shapes();
