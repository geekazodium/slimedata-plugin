@tool
extends EditorOperationExecutor
class_name AddOperationExecutor

var is_capsule: bool = false;

@export var confirm_event: InputEvent;

func get_operation_name() -> String:
	return "Add Shape";

func execute(editing_provider: FrameDataProviderTool) -> void:
	self.is_capsule = false;
	editing_provider.draw.connect(self.draw);

func request_cancel() -> void:
	self.get_editing_provider().draw.disconnect(self.draw);
	self.end_operation();

func draw() -> void:
	var editing_provider: FrameDataProviderTool = self.get_editing_provider();
	var local_mouse_pos: Vector2 = editing_provider.get_local_mouse_position();
	var radius: int = 10;
	if self.is_capsule:
		editing_provider.draw_circle(local_mouse_pos + Vector2.UP * radius,radius,Color.AQUA);
		editing_provider.draw_circle(local_mouse_pos - Vector2.UP * radius,radius,Color.AQUA);
		editing_provider.draw_rect(Rect2(local_mouse_pos - Vector2.ONE * radius, Vector2.ONE * 2 * radius), Color.AQUA);
	else:
		editing_provider.draw_circle(editing_provider.get_local_mouse_position(),radius,Color.AQUA);

func process(delta: float) -> void:
	pass;

func recieve_input(event: InputEvent) -> void:
	if event is InputEventWithModifiers:
		self.is_capsule = event.shift_pressed;
	if event.is_match(confirm_event, false):
		self.commit();

func commit() -> void:
	var shape: FunctionBoxShape;
	var mouse_pos: Vector2 = self.get_editing_provider().get_global_mouse_position();
	if self.is_capsule:
		shape = FunctionBoxCapsuleShape.new();
		shape.position1 = mouse_pos + Vector2.UP * 10;
		shape.position2 = mouse_pos - Vector2.UP * 10;
	else:
		shape = FunctionBoxCircleShape.new();
		shape.position = mouse_pos;
	self.get_editing_provider().add_shape(shape);
	self.get_editing_provider().draw.disconnect(self.draw);
	self.end_operation();
