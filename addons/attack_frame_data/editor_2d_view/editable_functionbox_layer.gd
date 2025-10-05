@tool
extends FunctionBoxLayer
class_name EditableFunctionBoxLayer

var push_count: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.allocate_shape_pool(10);
	self.input_event.connect(self.on_input_event);

func on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("ui_select"):
		print("oh");

@warning_ignore("unused_parameter")
func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void:
	pass

func clear() -> void:
	super.clear();
	self.push_count = 0;

func push_shape(shape_data: FunctionBoxShape, interp: bool) -> void:
	if self.push_count >= self.shape_pool.size():
		self._increment_pool_size();
	var shape: FunctionBoxCollisionShape2D = self.shape_pool[self.push_count];
	self.push_count += 1;
	shape_data.push_to_shape(
		shape,
		Vector2.ZERO,
		interp
	);
	shape.visible = true;
	shape.disabled = false;
