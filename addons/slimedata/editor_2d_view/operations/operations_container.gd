@tool
extends Node
class_name EditorOperationsContainer

@export var search_operation_node: Node;

func _ready() -> void:
	for node: Node in self.search_operation_node.get_children():
		var operation: EditorOperationExecutor = node as EditorOperationExecutor;
		if operation == null:
			continue;
		self.add_sibling.call_deferred(operation.register_operation());
