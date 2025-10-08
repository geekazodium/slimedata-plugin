@tool
extends FunctionBoxLayer
class_name EditableFunctionBoxLayer

var push_count: int = 0;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.allocate_shape_pool(10);
	self.input_pickable = true;
	self.monitoring = true;
	self.set_process(true);
	self.process_mode = Node.PROCESS_MODE_ALWAYS;

var selected_shape: FunctionBoxCollisionShape2D = null;
var start_select_pos: Vector2 = Vector2.ZERO;

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event.is_action("edit_hitbox_select"):
		if event.is_pressed(): 
			self.selected_shape = self.get_child(shape_idx); ##assumption, shape_idx == the index of child node
			self.start_select_pos = self.selected_shape.get_local_mouse_position();

func _process(delta: float) -> void:
	if self.selected_shape == null:
		return;
	self.selected_shape.global_position = self.get_global_mouse_position() - self.start_select_pos;

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
