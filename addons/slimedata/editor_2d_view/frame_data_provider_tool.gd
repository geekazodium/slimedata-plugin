@tool
extends FrameDataProvider
class_name FrameDataProviderTool

const DEFAULT_ANIM_NAME = "DEFAULT";
static var SELECT_ACTION: InputEventMouseButton = (func():
		var e = InputEventMouseButton.new();
		e.button_index = MOUSE_BUTTON_LEFT;
		e.device = -1;
		return e;).call(); ## init function to create a mouse left click event to compare to

@export var current_layer_editing: int = 0:
	get: 
		return euler_mod(current_layer_editing, FrameDataProvider.DATA_LAYER_COUNT);

## godot's modulo function is weird, A mod B where A is a negative integer,
## the result ends up being (A mod B) - B
static func euler_mod(a: int,mod: int)-> int:
	return ((a % mod) + mod) % mod

@export var current_frame_editing: int = 0:
	get:
		return clamp(current_frame_editing, 0, current_frame_data_cached.frames.size())

var shape_inputs: Array[Dictionary] = [];

signal clear_selection();

func _ready() -> void:
	super._ready();
	self._ensure_valid_state();
	self.update_shapes();

func _process(_delta: float) -> void:
	var highest_priority: Dictionary = {};
	for input in self.shape_inputs:
		if self.event_has_priority_over_other(input, highest_priority):
			highest_priority = input;
	self.shape_inputs.clear();
	if !highest_priority.is_empty():
		self._on_shape_input(highest_priority.event, highest_priority.shape, highest_priority.layer)

func _physics_process(_delta: float) -> void:
	self._physics_workaround_physics_process();

func _update_cached_anim() -> void:
	self._ensure_valid_state();
	super._update_cached_anim();

func _ensure_valid_state() -> void: 
	if self.frame_data.is_empty():
		self._create_default();
	
	## assertion: frame data must have at least one key, since if it's
	## empty, the previous statement will definitely have added a single key.
	if self.current_frame_data == "":
		self.current_frame_data = self.frame_data.keys()[0];

func _create_default() -> void:
	var frames: FrameData = FrameData.new();
	frames.frames.append(FrameDataFrame.new());
	self.frame_data.set(DEFAULT_ANIM_NAME, frames);

func next_frame() -> void:
	self.current_frame += 1;

func get_current_frame_editing() -> FrameDataFrame:
	if self.current_frame_data_cached == null:
		self._ensure_valid_state();
	return self.current_frame_data_cached.get_frame(self.current_frame_editing);

func update_shapes() -> void:
	var frame: FrameDataFrame = self.get_current_frame_editing();
	self.push_frame_to_shapes(frame, false);

func cycle_layer() -> void:
	self.current_layer_editing += 1;

func _on_layer_shape_input(event: InputEvent, shape: FunctionBoxCollisionShape2D, layer: EditableFunctionBoxLayer) -> void:
	if !event.is_match(SELECT_ACTION,false):
		return;
	self.shape_inputs.append({
		"event": event,
		"shape": shape,
		"layer": layer
	})

func event_has_priority_over_other(event: Dictionary, other: Dictionary) -> bool:
	if other.is_empty():
		return true;
	var event_same_layer: bool = event.get("layer") == self.get_current_layer();
	var other_same_layer: bool = other.get("layer") == self.get_current_layer();
	if event_same_layer && !other_same_layer:
		return true;
	if !event_same_layer && other_same_layer:
		return false;
	var mouse_pos: Vector2 = self.get_global_mouse_position();
	return mouse_pos.distance_squared_to(event.get("shape").global_position) < mouse_pos.distance_squared_to(other.get("shape").global_position);
	
func _on_shape_input(event: InputEvent, shape: FunctionBoxCollisionShape2D, layer: EditableFunctionBoxLayer) -> void:
	if event.is_pressed():
		if !self._is_event_shift(event):
			self.clear_selection.emit();
		if layer.is_shape_selected(shape):
			layer.unselect_shape(shape);
		else:
			layer.select_shape(shape);

func _is_event_shift(event: InputEvent) -> bool:
	var modified_event: InputEventWithModifiers = event as InputEventWithModifiers;
	if modified_event == null: 
		return false;
	return modified_event.shift_pressed;

func get_current_layer() -> EditableFunctionBoxLayer:
	return self.get_layer_by_index(self.current_layer_editing);

func add_shape() -> void:
	var frame: FrameDataFrame = self.get_current_frame_editing();
	var shape: FunctionBoxCircleShape = FunctionBoxCircleShape.new();
	shape.position = Vector2.from_angle(randf() * PI * 2) * randf_range(0,100);
	ToolSpaceUtils.add_shape(frame, self.current_layer_editing, shape);
	self.push_frame_to_shapes(frame, false);

func remove_shape(shape: FunctionBoxShape, push: bool) -> void:
	var frame: FrameDataFrame = self.get_current_frame_editing();
	ToolSpaceUtils.remove_shape(frame, shape);
	if push:
		self.push_frame_to_shapes(frame, false);

func _on_delete_button_pressed() -> void:
	for i in range(self.DATA_LAYER_COUNT):
		var layer: EditableFunctionBoxLayer = self.get_layer_by_index(i);
		for shape in layer._selected_shapes:
			if shape.shape_src.key != shape.key:
				push_error("something is wrong with the internal state");
			self.remove_shape(shape.shape_src, false);
		layer.clear_selected();
	var frame: FrameDataFrame = self.get_current_frame_editing();
	self.push_frame_to_shapes(frame, false);

func push_frame_to_shapes(frame: FrameDataFrame, interp: bool) -> void:
	self._force_clickable_area_update();
	super.push_frame_to_shapes(frame, interp);

# Physics shape selection workaround: godot for some goddamnn reason, does not like
# it when the shapes are moved around and will drop all physics mouse click events
# from registering if the shapes, such as here, get shifted around a lot.
# moving the shape and then resetting the shape's position on the physics frame
# seems to be an effective workaround, 

# this workaround fixes the issue of shapes not being selectable after they get
# reassigned and pushed (admittedly an inefficient process but needed to ensure
# a valid state, I have not built this with the most optimized editor in mind.)

# I suspect it could be something to do with 
# the engine trying to be efficient and not updating the mouse selectable areas
# until needed, which apparently does not include removal and reorientation of
# shapes.
var workaround_reset_needed: bool = false;

func _force_clickable_area_update() -> void:
	self.position = Vector2.UP * 1000;
	self.workaround_reset_needed = true;

func _physics_workaround_physics_process() -> void:
	if !self.workaround_reset_needed:
		return;
	self.workaround_reset_needed = false;
	self.position = Vector2.ZERO;
