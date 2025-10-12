@tool
extends EditorOperationExecutor
class_name GrabOperationExecutor

var selected_shapes: Array[EditableShape2D] = [];
var grab_start_pos: Vector2;
var starting_postions: PackedVector2Array = [];

func get_operation_name() -> String:
	return "Grab";

func get_offset() -> Vector2:
	return self.get_editing_provider().get_global_mouse_position() - self.grab_start_pos;

func execute(editing_provider: FrameDataProviderTool) -> void:
	self.selected_shapes = editing_provider.get_selected_shapes();
	self.grab_start_pos = editing_provider.get_global_mouse_position();
	self.starting_postions.resize(self.selected_shapes.size());
	for i in range(self.selected_shapes.size()):
		self.starting_postions[i] = self.selected_shapes[i].global_position;

func request_cancel() -> void:
	for i in range(self.selected_shapes.size()):
		self.selected_shapes[i].global_position = self.starting_postions[i];
	self.end_operation();

func commit() -> void:
	var offset: Vector2 = self.get_offset();
	for s in self.selected_shapes:
		s.move_by(offset);
	self.get_editing_provider().force_clickable_area_update();
	self.end_operation();

func process(delta: float) -> void:
	var offset: Vector2 = self.get_offset();
	for i in range(self.selected_shapes.size()):
		self.selected_shapes[i].global_position = self.starting_postions[i] + offset;

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.commit();
