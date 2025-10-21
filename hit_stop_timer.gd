extends Node

var frames_left: int = 0;

func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS;

func set_hitstop(frames: int) -> void:
	self.get_tree().paused = true;
	self.frames_left = max(frames - 1, self.frames_left);

func _physics_process(_delta: float) -> void:
	if self.frames_left > 0:
		self.frames_left -= 1;
		if self.frames_left == 0:
			self.get_tree().paused = false;
