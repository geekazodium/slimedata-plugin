@abstract
@tool
extends Node
class_name EditorOperationExecutor

@export var shortcut: Shortcut;
var button: Button;

var _container: EditorOperationsContainer;

@abstract
func execute(editing: FrameDataProviderTool) -> void;

@abstract
func get_operation_name() -> String;

func get_editing_provider() -> FrameDataProviderTool:
	return self._container.editing_provider;

func attempt_execute() -> void:
	if self._container.is_editing():
		if !self._container.try_cancel():
			return;
	self._container.edit_start(self);
	self.execute(self.get_editing_provider());

func end_operation() -> void:
	self._container.edit_complete();

@abstract
func process(delta: float) -> void;

@abstract
func request_cancel() -> void;

func _handle_input(event: InputEvent) -> void:
	return;

static var CANCEL_KEY: InputEventKey = (func():
	var event = InputEventKey.new();
	event.keycode = KEY_ESCAPE;
	return event;
).call();

func recieve_input(event: InputEvent) -> void:
	if CANCEL_KEY.is_match(event, false):
		self.request_cancel();
	else:
		self._handle_input(event);

func register_operation(container: EditorOperationsContainer) -> Button:
	self.button = Button.new();
	self.button.shortcut = shortcut;
	self._container = container;
	self.button.pressed.connect(self.attempt_execute);
	self._update_button_text();
	return self.button;

func _update_button_text() -> void:
	self.button.text = self.get_operation_name();
