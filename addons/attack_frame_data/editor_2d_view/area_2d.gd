@tool
extends CollisionShape2D

var hold_start: Vector2 = Vector2.ZERO;
var held: bool = false;

## NOTE; THIS IS 10005 SPAGHETTI, FIXME FIXME FIXME: MAKE THIS ACTUALLY LINK UP TO THE 
## FRAME DATA AND MAKE SURE IT'S NOT A MESS, CURRENTLY, THE SHAPE HANDLES
## COLLISIONS FOR THE WHOLE AREA 2D.

## HOWEVER, this is a proof that the drag to move feature for the hitboxes is completely doable
## a promising start, but just a start.
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton;
	if event == null:
		return;
	if self.held: 
		return;
	self.held = true;
	self.hold_start = self.get_local_mouse_position();
	return;

## update position on process frame to make sure it's as close as can get to actual mouse
## position when dropped.
func _process(delta: float) -> void:
	if self.held:
		if !Input.is_anything_pressed():
			self.held = false;
			self.get_parent().position += self.position;
			self.position = Vector2.ZERO;
			return;
		self.global_position = self.get_global_mouse_position() - self.hold_start;
