@tool
extends Button
class_name FrameIndexEdit

var frame: FrameDataFrame;
var index: int;
var highlight: bool = false:
	set(value):
		highlight = value;
		if self.is_inside_tree():
			self.queue_redraw();
			self.grab_focus();

var held: bool = false;

func update_position(time_scale: float) -> void:
	var t: float = self.frame.frame_index;
	t *= time_scale;
	self.text = String.num_int64(self.frame.frame_index);
	self.position = Vector2.RIGHT * t;

func _process(delta: float) -> void:
	if self.held:
		self.position.x += self.get_local_mouse_position().x;

func _draw() -> void:
	if self.highlight:
		self.draw_circle(self.size * .5, 20, Color.ORANGE, false, 2, true);

func _get_parent_container() -> FrameOrderContainer:
	return self.get_parent() as FrameOrderContainer;

func _pressed() -> void:
	self._get_parent_container().select_frame(self.index);
	self.held = true;

func _gui_input(event: InputEvent) -> void:
	if !event is InputEventMouseButton:
		return;
	
	if !(event.is_released() && 
		event.button_index == MouseButton.MOUSE_BUTTON_LEFT):
		return;
	
	self.held = false;
	self._get_parent_container().update_frame_index(self.index, self._get_mouse_frame());

func _get_mouse_frame() -> int:
	return round(self.position.x / self._get_parent_container().time_scale);
