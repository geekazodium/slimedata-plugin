@tool
extends EditorOperationExecutor
class_name ScaleOperationExecutor

var selected_shapes: Array[EditableShape2D] = [];
var scale_start_pos: Vector2;
var starting_magnitude: float = 0;
var starting_radius: PackedFloat64Array = [];

func get_operation_name() -> String:
	return "Scale Radius";

func get_magnitude() -> float:
	return (self.get_editing_provider().get_global_mouse_position() - self.scale_start_pos).length() - self.starting_magnitude;

func execute(editing_provider: FrameDataProviderTool) -> void:
	self.selected_shapes = editing_provider.get_selected_shapes();
	self.starting_radius.resize(self.selected_shapes.size());
	self.scale_start_pos = Vector2.ZERO;
	
	var individual_weight: float = 1. / float(self.selected_shapes.size());
	for i in range(self.selected_shapes.size()):
		self.scale_start_pos += individual_weight * self.selected_shapes[i].global_position;
		self.starting_radius[i] = self.selected_shapes[i].shape_src.radius;
	
	self.starting_magnitude = 0;
	self.starting_magnitude = self.get_magnitude();

func request_cancel() -> void:
	self.get_editing_provider().update_shapes();
	self.get_editing_provider().force_clickable_area_update();
	self.end_operation();

func commit() -> void:
	var scale_change: float = self.get_magnitude();
	for s in self.selected_shapes:
		s.add_to_radius(scale_change);
	self.get_editing_provider().update_shapes();
	self.get_editing_provider().force_clickable_area_update();
	self.end_operation();

func process(delta: float) -> void:
	var scale_change: float = self.get_magnitude();
	for i in range(self.selected_shapes.size()):
		self.selected_shapes[i].push_radius_tmp(self.starting_radius[i] + scale_change);

func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			self.commit();
