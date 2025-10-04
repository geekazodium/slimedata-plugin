extends Node

@export var play: StringName;

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		$"../FrameDataProvider".play_framedata(play);
