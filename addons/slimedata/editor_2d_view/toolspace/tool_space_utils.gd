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
	reassign_index(provider.current_frame_data_cached);

## reassigns indicies for all shapes in the frame data.
static func reassign_index(frame_data: FrameData) -> void:
	print("reassigning reserved indicies for ", frame_data);
	var last_frame: FrameDataFrame = null;
	
	var last_frame_ids: Array[int];
	var last_frame_id_partitions: PackedInt64Array = range(FrameDataProvider.DATA_LAYER_COUNT);
	for frame in frame_data.frames:
		if last_frame == null:
			last_frame_ids = _update_frame_indicies_trivial(frame, last_frame_id_partitions);
		else:
			last_frame_ids = _update_frame_indices_with_last_frame(frame, last_frame_ids, last_frame_id_partitions);
		last_frame = frame;

static func _update_frame_indicies_trivial(frame: FrameDataFrame, id_partitions: PackedInt64Array) -> Array[int]:
	var indicies: Array[int] = [];
	for layer_index: int in range(FrameDataProvider.DATA_LAYER_COUNT):
		var count: int = 0;
		for i in frame.get_layer_range(layer_index):
			frame.shapes[i].reserved_index = count;
			indicies.append(count);
			count += 1;
	
	## shortcut, given that there will not be any empty spaces,
	## skip computing where each layer will end because the space does not change
	for i in range(FrameDataProvider.DATA_LAYER_COUNT):
		id_partitions[i] = frame.layer_end_idxs[i];
	return indicies;

const _UNUSED_INDEX: int = -1;
## assigns new indicies for shapes based on indicies that have been reserved last
## frame, updates id_partitions after using it to store this frames reserved indicies
static func _update_frame_indices_with_last_frame(frame: FrameDataFrame, last_frame_indexs: Array[int], id_partitions: PackedInt64Array) -> Array[int]:

	
	var indicies: Array[int] = [];
	var new_layers_partition: Array[int] = [];
	var new_partition_end: int = 0;
	var last_layer_partition_end: int = 0;
	
	for layer_index: int in range(FrameDataProvider.DATA_LAYER_COUNT):
		var count: int = 0;
		var keys_shapes: Dictionary[int, Array] = _get_taken_keys(frame, layer_index);
		## copy to existing indicies
		for i in range(last_layer_partition_end, id_partitions[layer_index]):
			if keys_shapes.is_empty():
				break;
			#print(last_frame_indexs, ",", id_partitions[layer_index]);
			var last_key: int = last_frame_indexs[i];
			indicies.append(_try_insert_shape(keys_shapes,last_key,count));
			count += 1;
		
		## add leftovers
		for key: int in keys_shapes.keys():
			var shapes: Array = keys_shapes.get(key);
			for shape in shapes:
				
				## these must be called together
				shape.reserved_index = count;
				indicies.append(shape.key);
				
				count += 1;
		#print(last_layer_partition_end ,",", id_partitions[layer_index]);
		last_layer_partition_end = id_partitions[layer_index];
		
		## increase partition size
		new_partition_end += count;
		new_layers_partition.append(new_partition_end);
	
	for i in range(FrameDataProvider.DATA_LAYER_COUNT):
		id_partitions[i] = new_layers_partition[i];
	return indicies;

## if the keys that exists in this frame still has something ovelapping with
## the last, or if it was unused, take that and write it there, otherwise add an unused
static func _try_insert_shape(keys_shapes: Dictionary[int, Array], last_key: int, count: int) -> int:
	if keys_shapes.has(last_key) || last_key == _UNUSED_INDEX:
		var eff_last_key = last_key;
		if eff_last_key == _UNUSED_INDEX:
			eff_last_key = keys_shapes.keys()[0];
		
		var shapes: Array = keys_shapes.get(eff_last_key);
		var shape: FunctionBoxShape = shapes.pop_front();
		if shapes.is_empty():
			keys_shapes.erase(eff_last_key);
			
		## these must be called together
		shape.reserved_index = count;
		return shape.key;
	return _UNUSED_INDEX;

static func _get_taken_keys(frame: FrameDataFrame, layer_index: int) -> Dictionary[int, Array]:
	var taken_keys: Dictionary[int, Array] = {};
	for index: int in frame.get_layer_range(layer_index):
		var shape: FunctionBoxShape = frame.shapes[index];
		var arr: Array = taken_keys.get_or_add(shape.key, []);
		arr.push_back(shape);
	return taken_keys;
