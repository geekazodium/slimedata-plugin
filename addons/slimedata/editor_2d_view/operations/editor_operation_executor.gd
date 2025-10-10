@abstract
@tool
extends Node
class_name EditorOperationExecutor

@export var shortcut: Shortcut;
var button: Button;

@abstract
func execute() -> void;

@abstract
func get_operation_name() -> String;

func register_operation() -> Button:
	self.button = Button.new();
	self._update_button_text();
	self.button.shortcut = shortcut;
	self.button.pressed.connect(self.execute);
	return self.button;

func _update_button_text() -> void:
	self.button.text = self.get_operation_name();
