@tool
extends Control

class_name FrameOrderContainer

var time_scale: float = 100;

@export var editing_provider: FrameDataProviderTool;
@export var frame_index_edit: PackedScene;

var current_edit_indexes: Array[FrameIndexEdit] = [];
var bound_edit: FrameIndexEdit:
	get:
		if current_edit_indexes.size() == 0:
			return null;
		return current_edit_indexes[current_edit_indexes.size() - 1];

func _ready() -> void:
	if self.editing_provider == null:
		return;
	self.editing_provider.current_frame_data_changed.connect(self.on_frame_data_change);
	self.update_edit_ui.call_deferred();

func get_current_frame_data() -> FrameData:
	return self.editing_provider.current_frame_data_cached;

func get_current_frame_index() -> int:
	return self.editing_provider.current_frame_editing;

func on_frame_data_change(frame_data: FrameData) -> void:
	self.update_edit_ui();

func update_edit_ui() -> void:
	self.clear_edit_ui();
	
	var count: int = 0;
	for frame in self.get_current_frame_data().frames:
		var index_edit: FrameIndexEdit = frame_index_edit.instantiate() as FrameIndexEdit;
		self.add_child(index_edit);
		index_edit.frame = frame;
		index_edit.index = count;
		self.current_edit_indexes.append(index_edit);
		index_edit.update_position(self.time_scale);
		count += 1;
	
	self._update_frame_selected();

func select_frame(index: int) -> void:
	self._clear_frame_selected();
	self.editing_provider.current_frame_editing = index;
	self._update_frame_selected();

func _process(delta: float) -> void:
	var min_size: Vector2 = Vector2(20,20);
	if self.bound_edit != null:
		min_size = self.bound_edit.size;
		min_size.x += self.bound_edit.position.x + time_scale;
	if self.custom_minimum_size != min_size:
		self.queue_redraw();
		self.custom_minimum_size = min_size;

func clear_edit_ui() -> void:
	for edit in self.current_edit_indexes:
		edit.free();
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

func update_frame_index(index: int, new_frame_index: int) -> void:
	self.get_current_frame_data().get_frame(index).frame_index = new_frame_index;
	ToolSpaceUtils.sort_frames(self.get_current_frame_data());
	self.update_edit_ui();

func _update_frame_selected() -> void:
	self.current_edit_indexes[self.get_current_frame_index()].highlight = true;

func _clear_frame_selected() -> void:
	self.current_edit_indexes[self.get_current_frame_index()].highlight = false;
