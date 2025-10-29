extends Node

@export var play: StringName;
@export var frame_data_provider: FrameDataProvider;
var last_x_positive: bool = false;
@export var character_body: CharacterBody2D;

var x_scale: float:
	get:
		return 1 if self.last_x_positive else -1;

func _physics_process(_delta: float) -> void:
	if -sign(x_scale) == sign(self.character_body.velocity.x):
		self.last_x_positive = !self.last_x_positive;
	if Input.is_action_just_pressed("attack"):
		frame_data_provider.play_framedata(play);
		frame_data_provider.transform_matrix.x = x_scale;
