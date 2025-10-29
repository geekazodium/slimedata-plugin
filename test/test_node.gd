extends Node

@export var play: StringName;
@export var frame_data_provider: FrameDataProvider;

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("attack"):
		frame_data_provider.play_framedata(play);
