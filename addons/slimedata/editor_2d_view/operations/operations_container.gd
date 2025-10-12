@tool
extends Node
class_name EditorOperationsContainer

@export var search_operation_node: Node;
@export var editing_provider: FrameDataProviderTool;

var _current_operation: EditorOperationExecutor = null;

func _ready() -> void:
	for node: Node in self.search_operation_node.get_children():
		var operation: EditorOperationExecutor = node as EditorOperationExecutor;
		if operation == null:
			continue;
		self.add_sibling.call_deferred(operation.register_operation(self));

func _process(delta: float) -> void:
	if self.is_editing():
		self._current_operation.process(delta);

func edit_start(operation: EditorOperationExecutor) -> void:
	self._current_operation = operation;

func edit_complete() -> void:
	self._current_operation = null;

func is_editing() -> bool:
	return self._current_operation != null;

func try_cancel() -> bool:
	if self._current_operation != null:
		self._current_operation.request_cancel();
	return self.is_editing();
