@tool
extends Node
class_name SlimeEditableObjectFactory

@export var editable_provider: FrameDataProviderTool;

## only one instance needed, allocating excess mem is not a good idea
static var select_file_dialog: EditorFileDialog;
var added: bool = false;

var editing_nodes: Node2D:
	set(val):
		if editing_nodes != null:
			_unload_loaded_scene();
		editing_nodes = val;

func _ready() -> void:
	if !Engine.is_editor_hint():
		return;
	if self.select_file_dialog == null:
		var dialog: EditorFileDialog = EditorFileDialog.new();
		dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE;
		dialog.access = EditorFileDialog.ACCESS_RESOURCES;
		dialog.size = Vector2i(1980,1080);
		dialog.add_filter("*.tscn, *.scn", "Edit Framedata in Scenes");
		dialog.file_selected.connect(self.dialog_on_file_selected);
		self.select_file_dialog = dialog;

func show_select_editable_dialog() -> void:
	if !self.added:
		EditorInterface.popup_dialog_centered(self.select_file_dialog);
		self.added = true;
	self.select_file_dialog.show();

func dialog_on_file_selected(path: String) -> void:
	var f = load(path);
	if !(f is PackedScene):
		push_warning("invalid path selected");
		f.free();
		return;
	print("loading file into editor...");
	self.load_scene_as_editable(f);

func load_scene_as_editable(scene: PackedScene) -> void:
	self.editing_nodes = scene.instantiate();
	self.search_animation_players(self.editing_nodes);

func search_animation_players(node: Node) -> void:
	var animation_players: Array[Node] = node.find_children("*", "AnimationPlayer");
	for player: Node in animation_players:
		if player is AnimationPlayer:
			print("animation player found: ", player);
			for s in player.get_animation_list():
				print(s);

func save_loaded_scene() -> void:
	return;

## automatically called when editing nodes is set and the value before
## setting is not null.
func _unload_loaded_scene() -> void:
	self.editing_nodes.queue_free();
