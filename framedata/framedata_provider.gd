@tool
extends Node2D
class_name FrameDataProvider

const DATA_LAYERS: Array[StringName] = [
	"HurtBox",
	"HitBox",
	"ShieldBox"
];

const DATA_LAYER_COUNT: int = 3;

@export var frame_data: Dictionary[StringName, FrameData] = {}

@export var current_frame_data: StringName = "":
	set(value):
		current_frame_data = value;
		current_frame_data_cached = frame_data[value];
var current_frame_data_cached: FrameData; 

var current_frame: int = 0;
var current_data_index: int = 0;

var last_frame_position: Vector2 = Vector2.ZERO;

func reset_animation() -> void:
	self.current_frame = 0;
	self.current_data_index = 0;

func play_framedata(key: StringName) -> void:
	self.reset_animation();
	self.current_frame_data = key;

func _physics_process(_delta: float) -> void:
	if self.current_frame_data == "":
		return;
	var next_frame: int = self.current_frame + 1;
	var next_data_index: int = self.current_data_index + 1;
	var next_frame_data: FrameDataFrame = self.current_frame_data_cached.get_frame(next_data_index);
	if next_frame_data == null:
		return;
	self.current_frame = next_frame;
	if next_frame_data.frame_index < next_frame:
		##BREAKPOINT HERE, SOMETHING WENT WRONG TO GET THIS TO HAPPEN.
		push_warning("framedata frame skipped, what happened??");
	if next_frame_data.frame_index == next_frame:
		self.current_data_index = next_data_index;
		self.push_frame_to_shapes(next_frame_data);

func push_frame_to_shapes(frame: FrameDataFrame) -> void:
	for layer_idx: int in range(DATA_LAYER_COUNT):
		for i in frame.get_layer_range(layer_idx):
			var shape: FunctionBoxShape = frame.shapes[i];
			shape.push
			
