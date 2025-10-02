extends Resource
class_name FrameData

@export var frames: Array[FrameDataFrame];

func get_frame(index: int) -> FrameDataFrame:
	if self.frames.size() <= index:
		return null;
	return self.frames[index];
