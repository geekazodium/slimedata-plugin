@tool
extends Resource
class_name FrameDataProviderInspector

var inspecting: FrameDataProviderTool;

@export var frame_data_library: Dictionary[StringName, FrameData]:
	get:
		return inspecting.frame_data;
	set(value):
		inspecting.frame_data = value;

@export var current_data_key_index: int = 0:
	get:
		var library_size: int = frame_data_library.size();
		return _clamp_library_size(current_data_key_index);
	set(value):
		current_data_key_index = _clamp_library_size(value);
		current_data_key = self.frame_data_library.keys()[current_data_key_index];

@export var current_data_key: StringName:
	get:
		return inspecting.current_frame_data;
	set(value):
		inspecting.current_frame_data = value;

func _clamp_library_size(index: int) -> int:
	var library_size: int = self.frame_data_library.size();
	return clampi(index, 0, library_size - 1);
