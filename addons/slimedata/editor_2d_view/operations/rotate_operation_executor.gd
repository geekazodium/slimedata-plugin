@tool
extends EditorOperationExecutor
class_name RotateOperationExecutor

var selected_shapes: Array[EditableShape2D] = [];
var rotate_start_pos: Vector2;
var rotate_center: Vector2;
var starting_postions: PackedVector2Array = [];
var starting_angles: PackedFloat64Array = [];

func get_operation_name() -> String:
	return "Rotate";

func get_rotate_radians() -> float:
	var diff: Vector2 = self.get_editing_provider().get_global_mouse_position() - self.rotate_center;
	return diff.angle() - self.rotate_start_pos.angle();

func execute(editing_provider: FrameDataProviderTool) -> void:
	self.selected_shapes = editing_provider.get_selected_shapes();
	self.starting_postions.resize(self.selected_shapes.size());
	self.starting_angles.resize(self.selected_shapes.size());
	self.rotate_center = Vector2.ZERO;
	
	var individual_weight: float = 1. / float(self.selected_shapes.size());
	for i in range(self.selected_shapes.size()):
		self.starting_postions[i] = self.selected_shapes[i].global_position;
		self.rotate_center += individual_weight * self.starting_postions[i];
	for i in range(self.selected_shapes.size()): 
		self.starting_angles[i] = self.selected_shapes[i].global_rotation;
		self.starting_postions[i] -= rotate_center;
		
	self.rotate_start_pos = editing_provider.get_global_mouse_position() - self.rotate_center;

func request_cancel() -> void:
	for i in range(self.selected_shapes.size()):
		var shape: EditableShape2D = self.selected_shapes[i];
		shape.global_position = self.starting_postions[i] + rotate_center;
		shape.global_rotation = self.starting_angles[i];
	self.end_operation();

func commit() -> void:
	var angle: float = self.get_rotate_radians();
	for i in range(self.selected_shapes.size()):
		var shape: EditableShape2D = self.selected_shapes[i];
		shape.global_rotation = self.starting_angles[i] + angle;
		shape.move_by(self.starting_postions[i].rotated(angle) - self.starting_postions[i]);
		shape.rotate_by(angle);
	self.get_editing_provider().force_clickable_area_update();
	self.end_operation();

func process(delta: float) -> void:
	var angle: float = self.get_rotate_radians();
	for i in range(self.selected_shapes.size()):
		var shape: EditableShape2D = self.selected_shapes[i];
		shape.global_rotation = self.starting_angles[i] + angle;
		shape.global_position = self.starting_postions[i].rotated(angle) + self.rotate_center;

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.commit();
