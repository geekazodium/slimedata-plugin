@tool
extends EditorOperationExecutor
class_name CycleLayerOperationExecutor

func get_operation_name() -> String:
	return "Cycle Layer: %s" % [self.get_editing_provider().get_current_layer_name()];

func execute(editing_provider: FrameDataProviderTool) -> void:
	editing_provider.cycle_layer();
	self._update_button_text();
	self.end_operation();

func request_cancel() -> void:
	return;

func process(delta: float) -> void:
	pass;
