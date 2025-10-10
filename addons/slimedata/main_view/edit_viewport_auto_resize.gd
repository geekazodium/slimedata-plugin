@tool
extends SubViewport
class_name AutoResizingViewport

## AutoResizingViewport is tool-space Viewport updating to ensure 
## viewport matches the size of the control element it's presented
## on, but can have the x, and y components seperated in case weird
## behavior comes from copying x values in a Vbox layout or vice-versa

@export var size_source_x: Control;
@export var size_source_y: Control;

@export var size_padding: Vector2i;

func _process(delta: float) -> void:
	var new_size: Vector2i = Vector2i(self.size_source_x.size.x, self.size_source_y.size.y);
	if self.size != new_size:
		self.size = new_size + self.size_padding;
