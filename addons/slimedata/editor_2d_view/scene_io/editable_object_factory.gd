@tool
extends Node
class_name SlimeEditableObjectLoader

const SEARCH: String = "AnimationPlayerEditor";

@export var editable_provider: FrameDataProviderTool;

## only one instance needed, allocating excess mem is not a good idea
static var select_file_dialog: EditorFileDialog;
var added: bool = false;

var editing_nodes: Node2D:
	set(val):
		if editing_nodes != null:
			_unload_loaded_scene();
		editing_nodes = val;
		_search_frame_data_providers(editing_nodes);

## list of frame data providers in the nodes that are being edited
## empty if none are found OR if currently not editing any scene
var cached_frame_data_providers: Array[FrameDataProvider] = [];

var selected_frame_data_provider: FrameDataProvider = null;

signal cached_data_providers_updated(new: Array[FrameDataProvider]);

func _search_frame_data_providers(node: Node) -> void:
	self.cached_frame_data_providers = [];
	# return if method here is called with null node parameter,
	# effectively reset this and do NOT attempt load of anything 
	# if and only if the current editing is set to null.
	if node == null:
		return;
	var frame_data_providers: Array[Node] = node.find_children("*", "FrameDataProvider");
	for provider: Node in frame_data_providers:
		if provider is FrameDataProvider:
			self.cached_frame_data_providers.append(provider);

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
	self.edit_provider(0);

func edit_provider(index: int) -> void:
	if index >= self.cached_frame_data_providers.size() || index < 0:
		push_warning("attempting to edit index that does not exist");
		return;
	self.selected_frame_data_provider = self.cached_frame_data_providers[index];
	self._load_framedata();

func _load_framedata() -> void:
	## CAUTION: DO NOT LET `_force_valid_state` TO RUN AFTER THIS HAS BEEN RUN
	## OR IT WILL ERASE ALL DATA STORED IN THE CURRENT REFERENCE.
	self.editable_provider.frame_data = self.selected_frame_data_provider.frame_data;
	# call `_ensure_valid_state` indirectly by setting this var
	self.editable_provider.current_frame_data = "";
	self.editable_provider.current_frame_editing = 0;
	self.editable_provider.push_current_frame_to_shapes();

func save_loaded_scene() -> void:
	ToolSpaceUtils.save_optimized(self.editable_provider);

## automatically called when editing nodes is set and the value before
## setting is not null.
func _unload_loaded_scene() -> void:
	self.editing_nodes.free();
