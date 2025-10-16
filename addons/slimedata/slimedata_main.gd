@tool
extends EditorPlugin
class_name FunctionBoxDataMain

var main_panel_instance: Node;
var main_panel_scene: PackedScene = preload("uid://dflgv2gg0ipyv");

func _enable_plugin() -> void:
	pass

func _disable_plugin() -> void:
	pass

func _enter_tree() -> void:
	self.main_panel_instance = self.main_panel_scene.instantiate();
	EditorInterface.get_editor_main_screen().add_child(self.main_panel_instance);
	self._make_visible(false);

func _make_visible(visible: bool) -> void:
	self.main_panel_instance.visible = visible;

func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free();

func _has_main_screen() -> bool:
	return true;

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons");

func _get_plugin_name() -> String:
	return "SlimeData"
