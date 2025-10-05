@tool
class_name ToolSpaceUtils

static func add_shape(frame: FrameDataFrame, layer: int, shape: FunctionBoxShape) -> void:
	## optimization: order of items in array do not need to be kept, only order
	## of partitions, o(n) and o(p) where n is the total size of array whereas p is the number of partitions
	## the factor p is constant and defined as 3, therefore it can be argued this is O(1) time, and this
	## lines up with observation from profiling.
	
	var layer_count: int = frame.layer_end_idxs.size();
	var to_insert: FunctionBoxShape = shape;
	var last_index = -1;
	for i in range(layer, layer_count):
		var index: int = frame.get_layer_end(i);
		if last_index == index:
			continue;
		last_index = index;
		if index >= frame.shapes.size():
			frame.shapes.append(to_insert);
			break;
		else:
			var tmp = frame.shapes[index];
			frame.shapes[index] = to_insert;
			to_insert = tmp;
	for i in range(layer, layer_count):
		frame.layer_end_idxs[i] += 1;
