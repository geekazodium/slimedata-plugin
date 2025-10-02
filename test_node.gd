extends Node

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		print("ui accept pressed");
		$"../FrameDataProvider".play_framedata("idle");
