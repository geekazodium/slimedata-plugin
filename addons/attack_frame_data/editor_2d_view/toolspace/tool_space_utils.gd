@tool
class_name ToolSpaceUtils

static func add_shape(frame: FrameDataFrame, layer: int, shape: FunctionBoxShape) -> void:
	var layer_count: int = frame.layer_start_idxs.size();
	if layer + 1 >= layer_count:
		frame.shapes.append(shape);
		return;
	
	## optimization: order of items in array do not need to be kept, only order
	## of partitions, o(n) and o(p) where n is the total size of array whereas p is the number of partitions
	## the factor p is constant and defined as 3, therefore it can be argued this is O(1) time, and this
	## lines up with observation from profiling.
	var initial_size: int = frame.shapes.size();
	var to_insert: FunctionBoxShape = shape;
	var last_index: int = -1;
	for i in range(layer, layer_count):
		var index: int = _get_shape_index(frame, i, initial_size);
		if index == last_index:
			continue;
		if index >= frame.shapes.size():
			frame.shapes.append(to_insert);
			break;
		else:
			var tmp = frame.shapes[index];
			frame.shapes[index] = to_insert;
			to_insert = tmp;
	for i in range(layer + 1, layer_count):
		frame.layer_start_idxs[i] += 1;

static func _get_shape_index(frame: FrameDataFrame, layer: int, default: int) -> int:
	if frame.layer_start_idxs.size() <= layer + 1:
		return default;
	else:
		return frame.layer_start_idxs[layer + 1];
