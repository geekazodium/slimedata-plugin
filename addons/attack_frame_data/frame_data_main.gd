@tool
extends EditorPlugin
class_name SlimeDataMain

func _enable_plugin() -> void:
	# Add autoloads here.
	pass


func _disable_plugin() -> void:
	# Remove autoloads here.
	pass


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass

func _has_main_screen() -> bool:
	return true;

func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons");
