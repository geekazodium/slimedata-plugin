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

static func remove_shape(frame: FrameDataFrame, shape: FunctionBoxShape) -> void:
	if !frame.shapes.has(shape):
		push_error("failed to delete shape since shape was not found");
		return;
	var index = frame.shapes.find(shape);
	var layer_count: int = frame.layer_end_idxs.size();
	for i in range(layer_count):
		if frame.layer_end_idxs[i] > index:
			frame.layer_end_idxs[i] -= 1;
	frame.shapes.remove_at(index);

static func move_shape(shape: FunctionBoxShape, vec: Vector2) -> void:
	if shape is FunctionBoxCircleShape:
		shape.position += vec;
	
	if shape is FunctionBoxCapsuleShape:
		shape.position1 += vec;
		shape.position2 += vec;
	
static func rotate_shape(shape: FunctionBoxShape, radians: float) -> void:
	if shape is FunctionBoxCapsuleShape:
		var diff: Vector2 = (shape.position2 - shape.position1) * .5;
		var rotated_diff: Vector2 = diff.rotated(radians);
		var center: Vector2 = shape.position1 + diff;
		shape.position1 = center - rotated_diff;
		shape.position2 = center + rotated_diff;
	
static func add_shape_scale(shape: FunctionBoxShape, delta_r: float) -> void:
	if shape is FunctionBoxCircleShape:
		shape.radius += delta_r;
		shape.radius = max(shape.radius, .1);
	
	if shape is FunctionBoxCapsuleShape:
		shape.radius += delta_r;
		shape.radius = max(shape.radius, .1);

static func save_optimized(provider: FrameDataProviderTool) -> void:
	pass
