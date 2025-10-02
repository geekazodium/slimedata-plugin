@tool
extends Camera2D
class_name MouseControlledCamera

## fixme: not sure how to implement camera movement, or if I should
## maybe the editor camera movement can be bound to something else,
## using arrow/WASD could work, by I fear that can mess up the focus
## navigation that exists in the editor for godot, so I'm all in all
## quite hesitant to implement something here.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	return;
	Input.use_accumulated_input = false;
	#ProjectSettings.set_setting("input_devices/buffering/agile_event_flushing", true);
