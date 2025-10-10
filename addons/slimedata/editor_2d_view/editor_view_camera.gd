@tool
extends Camera2D
class_name EditorViewCamera

@export var move_shortcuts: Array[Shortcut];
var pressed: Array[bool] = [false, false, false, false];
const directions: PackedVector2Array = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT];
enum Direction{
	UP = 0,
	DOWN = 1,
	LEFT = 2,
	RIGHT = 3
}

@export var move_speed: float = 0;
## fixme: not sure how to implement camera movement, or if I should
## maybe the editor camera movement can be bound to something else,
## using arrow/WASD could work, by I fear that can mess up the focus
## navigation that exists in the editor for godot, so I'm all in all
## quite hesitant to implement something here.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	for i in range(self.pressed.size()):
		if self.move_shortcuts[i].matches_event(event):
			self.pressed[i] = event.is_pressed();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var move_speed_on_frame: float = self.move_speed * delta
	if self.pressed[Direction.UP] == self.pressed[Direction.DOWN]:
		pass
	elif self.pressed[Direction.UP]:
		self.position += move_speed_on_frame * Vector2.UP;
	else:
		self.position += move_speed_on_frame * Vector2.DOWN;
	
	if self.pressed[Direction.LEFT] == self.pressed[Direction.RIGHT]:
		pass
	elif self.pressed[Direction.LEFT]:
		self.position += move_speed_on_frame * Vector2.LEFT;
	else:
		self.position += move_speed_on_frame * Vector2.RIGHT;

func reset_position() -> void:
	self.position = Vector2.ZERO;
