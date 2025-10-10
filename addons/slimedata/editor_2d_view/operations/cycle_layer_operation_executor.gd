@tool
extends EditorOperationExecutor
class_name CycleLayerOperationExecutor

@export var editing_provider: FrameDataProviderTool;

func get_operation_name() -> String:
	return "Cycle Layer: %s" % [self.editing_provider.get_current_layer_name()];

func execute() -> void:
	self.editing_provider.cycle_layer();
	self._update_button_text();
