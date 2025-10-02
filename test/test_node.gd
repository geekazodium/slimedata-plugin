extends Node

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_focus_next"):
		$"../FrameDataProvider".play_framedata("idle");
