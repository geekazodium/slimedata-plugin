@tool
extends Label
class_name FrameIndexEdit

var frame: FrameDataFrame;
var highlight: bool = false:
	set(value):
		highlight = value;
		self.queue_redraw();

func update_position(time_scale: float) -> void:
	var t: float = self.frame.frame_index;
	t *= time_scale;
	self.text = String.num_int64(self.frame.frame_index);
	self.position = Vector2.RIGHT * t;

func _draw() -> void:
	if self.highlight:
		self.draw_circle(self.size * .5, 20, Color.ORANGE, false, 2, true);
