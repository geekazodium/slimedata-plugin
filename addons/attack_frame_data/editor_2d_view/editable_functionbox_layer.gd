@tool
extends FunctionBoxLayer
class_name EditableFunctionBoxLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.allocate_shape_pool(10);
	self.input_event.connect(self.on_input_event);

func on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("ui_select"):
		print("oh");
