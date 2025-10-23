extends Node2D
class_name FrameDataProvider

const DATA_LAYERS: Array[NodePath] = [
	"HurtBox",
	"HitBox",
	"ShieldBox"
];

const DATA_LAYER_COLORS: Dictionary[NodePath, int] = {
	"HurtBox": 0xd0ad0044,
	"HitBox": 0xd0000044,
	"ShieldBox": 0x69d80044
}

const DATA_LAYER_COUNT: int = 3;

@export var frame_data: Dictionary[StringName, FrameData] = {};

@export var current_frame_data: StringName = "":
	set(value): 
		current_frame_data = value;
		_update_cached_anim();
var current_frame_data_cached: FrameData; 

var current_frame: int = 0;
var current_data_index: int = 0;

var last_frame_position: Vector2 = Vector2.ZERO;

func _ready() -> void:
	self.physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF;
	for l in DATA_LAYERS:
		var layer: FunctionBoxLayer = self.get_layer(l);
		layer.default_debug_color = DATA_LAYER_COLORS[l];

func reset_animation() -> void:
	self.current_frame = 0;
	self.current_data_index = -1;
	for l in DATA_LAYERS:
		var layer: FunctionBoxLayer = self.get_layer(l);
		layer.clear_overlapped();

func play_framedata(key: StringName) -> void:
	self.reset_animation();
	self.current_frame_data = key;

func _update_cached_anim() -> void:
	self.current_frame_data_cached = self.frame_data[self.current_frame_data];

func _physics_process(_delta: float) -> void:
	if self.current_frame_data == "":
		return;
	var next_frame: int = self.current_frame + 1;
	var next_data_index: int = self.current_data_index + 1;
	## implement tag -> execute model of interpolation instead of current solution to prevent interp jank
	var this_frame_data: FrameDataFrame = self.current_frame_data_cached.get_frame(self.current_data_index);
	var next_frame_data: FrameDataFrame = self.current_frame_data_cached.get_frame(next_data_index);
	if next_frame_data == null:
		return;
	self.current_frame = next_frame;
	if next_frame_data.frame_index < next_frame:
		##BREAKPOINT HERE, SOMETHING WENT WRONG TO GET THIS TO HAPPEN.
		push_warning("framedata frame skipped, what happened??");
	if next_frame_data.frame_index == next_frame:
		self.current_data_index = next_data_index;
		var move_amount: Vector2 = self.global_position - self.last_frame_position;
		self.last_frame_position = self.global_position;
		self.push_frame_to_shapes(next_frame_data, true);
	elif self.current_data_index > 0:
		if this_frame_data.frame_index == next_frame - 1:
			self.push_frame_to_shapes(this_frame_data, false);

func push_frame_to_shapes(frame: FrameDataFrame, interp: bool) -> void:
	if self.get_child_count() == 0:
		print("no nodes to push data to, skipping...");
		return;
	for layer_idx: int in range(DATA_LAYER_COUNT):
		var layer: FunctionBoxLayer = self.get_layer(DATA_LAYERS[layer_idx]);
		layer.clear();
		for i in frame.get_layer_range(layer_idx):
			var shape: FunctionBoxShape = frame.shapes[i];
			layer.push_properties(shape);
			layer.push_shape(shape, interp);

func get_layer(path: NodePath) -> FunctionBoxLayer:
	return self.get_node(path) as FunctionBoxLayer;

func get_layer_by_index(index: int) -> FunctionBoxLayer:
	return self.get_layer(DATA_LAYERS[index]);
