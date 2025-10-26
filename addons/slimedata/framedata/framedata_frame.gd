@tool
extends Resource
class_name FrameDataFrame

const MIN_FRAME_INDEX: int = 1;

@export_range(MIN_FRAME_INDEX,-1,1,"or_greater") var frame_index: int = 1:
	set(index): 
		frame_index = max(MIN_FRAME_INDEX, index);
		if frame_index != index:
			push_warning("invalid frame index, frame data frames MUST start at frame %s" % [MIN_FRAME_INDEX]);

## mild spaghetti: there seems to be no better array initializer
@export var layer_end_idxs: PackedInt64Array = \
	range(FrameDataProvider.DATA_LAYER_COUNT).map(self._zero_elem); 

## function to map all elements to zero
func _zero_elem(_v: int) -> int:
	return 0;
	
@export var shapes: Array[FunctionBoxShape] = [];

func get_layer_end(layer_idx: int) -> int:
	if (layer_idx >= FrameDataProvider.DATA_LAYER_COUNT) || (layer_idx < 0):
		push_error("attempted access framedata layer that does not exist");
		return -1;
	return self.layer_end_idxs[layer_idx];

func get_layer_range(layer_idx: int) -> Array:
	var end_idx: int = self.get_layer_end(layer_idx);
	var start_at_zero: bool = layer_idx == 0;
	return range(0 if start_at_zero else self.get_layer_end(layer_idx - 1), end_idx);
