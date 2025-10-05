@tool
extends FrameDataProvider
class_name FrameDataProviderTool

const DEFAULT_ANIM_NAME = "DEFAULT";

@export var current_layer_editing: int = 0:
	get: 
		return euler_mod(current_layer_editing, FrameDataProvider.DATA_LAYER_COUNT);

static func euler_mod(a: int,mod: int)-> int:
	return ((a%mod)+mod)%mod

@export var current_frame_editing: int = 0:
	get:
		return clamp(current_frame_editing, 0, current_frame_data_cached.frames.size())

func _ready() -> void:
	super._ready();
	self._ensure_valid_state();
	self.update_shapes();
	self.set_physics_process(false);

func _ensure_valid_state() -> void: 
	if self.frame_data.is_empty():
		self._create_default();
	
	if self.current_frame_data == "":
		self.current_frame_data = DEFAULT_ANIM_NAME;

func _create_default() -> void:
	var frames: FrameData = FrameData.new();
	frames.frames.append(FrameDataFrame.new());
	self.frame_data.set(DEFAULT_ANIM_NAME, frames);

func next_frame() -> void:
	self.current_frame += 1;

func get_current_frame_editing() -> FrameDataFrame:
	return self.current_frame_data_cached.get_frame(self.current_frame_editing);

func update_shapes() -> void:
	var frame: FrameDataFrame = self.current_frame_data_cached.get_frame(self.current_frame_editing);
	self.push_frame_to_shapes(frame, false);

func cycle_layer() -> void:
	self.current_layer_editing += 1;

func add_shape() -> void:
	var frame: FrameDataFrame = self.get_current_frame_editing();
	var shape: FunctionBoxCircleShape = FunctionBoxCircleShape.new();
	shape.position = Vector2.from_angle(randf() * PI * 2) * randf_range(0,100);
	ToolSpaceUtils.add_shape(frame, self.current_layer_editing, shape);
	self.push_frame_to_shapes(frame,false);
