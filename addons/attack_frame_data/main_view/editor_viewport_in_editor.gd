@tool
extends SubViewportContainer
class_name EditorViewportInEditor

@export var sub_viewport: SubViewport;

## gui inputs detect all input on this GUI element, conveniently
## ensuring no events are passed from out of focus, and is
## at least from my testing, reliable on that behavior
func _gui_input(event: InputEvent) -> void:
	if !Engine.is_editor_hint():
		return;
	sub_viewport.push_input(event);

## disable ANY propagation since the propagation is handled
## by GUI input in tool script, using the built in propagation
## does not work in tool script space.
func _propagate_input_event(event: InputEvent) -> bool:
	return false;
