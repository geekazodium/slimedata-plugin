@tool
extends Control

class_name FrameOrderContainer

var time_scale: float = 100;

@export var editing_provider: FrameDataProviderTool;
@export var frame_index_edit: PackedScene;

var current_edit_indexes: Dictionary[int, FrameIndexEdit] = {};
var bound_edit: FrameIndexEdit = null;

func _ready() -> void:
	if self.editing_provider == null:
		return;
	self.editing_provider.current_frame_data_changed.connect(self.on_frame_data_change);
	self.update_edit_ui.call_deferred();

func get_current_frame_data() -> FrameData:
	return self.editing_provider.current_frame_data_cached;

func on_frame_data_change(frame_data: FrameData) -> void:
	self.update_edit_ui();

func update_edit_ui() -> void:
	self.clear_edit_ui();
	
	for frame in self.get_current_frame_data().frames:
		var index_edit: FrameIndexEdit = frame_index_edit.instantiate() as FrameIndexEdit;
		self.add_child(index_edit);
		index_edit.frame = frame;
		if self.editing_provider.get_current_frame_editing() == frame:
			index_edit.highlight = true;
		self.current_edit_indexes[self.get_next_valid_index(frame.frame_index)] = index_edit;
		index_edit.update_position(self.time_scale);
		self.bound_edit = index_edit;

func _process(delta: float) -> void:
	var min_size: Vector2 = Vector2(20,20);
	if self.bound_edit != null:
		min_size = self.bound_edit.size;
		min_size.x += self.bound_edit.position.x + time_scale;
	if self.custom_minimum_size != min_size:
		self.queue_redraw();
		self.custom_minimum_size = min_size;

func get_next_valid_index(index: int) -> int:
	var i = index;
	while self.current_edit_indexes.has(i):
		i += 1;
	return i;

func clear_edit_ui() -> void:
	for k in self.current_edit_indexes.keys():
		self.current_edit_indexes[k].free();
	self.current_edit_indexes.clear();

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,self.size),Color.DARK_BLUE * Color(0xffffff80));

func _previous_frame() -> void:
	self._clear_frame_selected();
	self.editing_provider.current_frame_editing -= 1;
	self._update_frame_selected();

func _next_frame() -> void:
	self._clear_frame_selected();
	self.editing_provider.current_frame_editing += 1;
	self._update_frame_selected();

func _update_frame_selected() -> void:
	var index: int = self.editing_provider.get_current_frame_editing().frame_index;
	self.current_edit_indexes[index].highlight = true;

func _clear_frame_selected() -> void:
	var index: int = self.editing_provider.get_current_frame_editing().frame_index;
	self.current_edit_indexes[index].highlight = false;
