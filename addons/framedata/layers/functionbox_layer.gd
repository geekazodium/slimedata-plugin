@abstract
extends Area2D
class_name FunctionBoxLayer

var shape_pool: Array[FunctionBoxCollisionShape2D] = [];
var next_shape_idx: int = 0;

var default_debug_color: Color: 
	set = _set_debug_col;

var overlapped: Dictionary[FunctionBoxLayer, Array] = {};

var alloc_max_id: int = 20;

func _set_debug_col(color: Color):
	default_debug_color = color;
	for instance in self.shape_pool:
		instance.debug_color = default_debug_color;

func clear_overlapped() -> void:
	for key in self.overlapped.keys():
		var res_hit_results: Array = self.overlapped.get(key); ##array: OverlapResult
		for i in res_hit_results:
			if i == null:
				continue;
			i.free();
	self.overlapped.clear();

func _ready() -> void:
	self.allocate_shape_pool(10); ## FIXME shape pool should be dynamically allocated based on the maximum
									## number of shapes that are ever needed.
	self.area_shape_entered.connect(self._on_area_shape_enter);

func get_overlap_for_layer(func_box_layer: FunctionBoxLayer) -> Array:
	if self.overlapped.has(func_box_layer):
		return self.overlapped[func_box_layer];
	
	var overlapped_by_id_index: Array = range(alloc_max_id);
	overlapped_by_id_index.fill(null);
	self.overlapped.set(func_box_layer, overlapped_by_id_index);

	return overlapped_by_id_index;

## buffer and reorder incoming collision events, typically this should be simple and fast, however...
## there's not much of a guarentee.
func _on_area_shape_enter(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	var other_func_box_layer: FunctionBoxLayer = area as FunctionBoxLayer;
	if other_func_box_layer == null:
		return;
	var layer_overlaps: Array = self.get_overlap_for_layer(other_func_box_layer);
	
	var local_shape_owner = shape_find_owner(local_shape_index);
	var local_shape: FunctionBoxCollisionShape2D = shape_owner_get_owner(local_shape_owner) as FunctionBoxCollisionShape2D;
	if local_shape == null: return;
	
	var other_shape_owner = area.shape_find_owner(area_shape_index);
	var other_shape: FunctionBoxCollisionShape2D = area.shape_owner_get_owner(other_shape_owner) as FunctionBoxCollisionShape2D;	
	if other_shape == null: return;
	
	var result: OverlapResult = layer_overlaps[local_shape.key];
	if result != null:
		if result.handled:
			return;
		if result.src.priority > local_shape.priority: 
			return;
		if result.src.priority == local_shape.priority:
			if result.hit.priority >= other_shape.priority:
				return;
		layer_overlaps[local_shape.key].src = local_shape.shape_src;
		layer_overlaps[local_shape.key].hit = other_shape.shape_src;
	else:
		layer_overlaps[local_shape.key] = OverlapResult.new_result(local_shape.shape_src, other_shape.shape_src);

func _physics_process(delta: float) -> void:
	for key in self.overlapped.keys():
		var res_hit_results: Array = self.overlapped.get(key); ##array: OverlapResult
		for i in res_hit_results:
			if i == null:
				continue;
			if i.handled:
				return;
			self._process_overlap(key,i.src,i.hit);
			i.handled = true; 

@abstract
func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void;

func get_framedata_provider() -> FrameDataProvider:
	return self.get_parent() as FrameDataProvider;

func allocate_shape_pool(size: int) -> void:
	for i in range(size):
		var instance: FunctionBoxCollisionShape2D = FunctionBoxCollisionShape2D.new();
		self.shape_pool.append(instance);
		self.add_child(instance);
		instance.debug_color = self.default_debug_color;
	self.clear();

func clear() -> void:
	self.next_shape_idx = 0;
	for shape in shape_pool:
		self._remove_shape(shape);

func _remove_shape(shape: FunctionBoxCollisionShape2D) -> void:
	shape.visible = false;
	shape.disabled = true;

## call this to push properties to shape before pushing actual shape.
func push_properties(shape_data: FunctionBoxShape) -> void:
	var shape: FunctionBoxCollisionShape2D = self.shape_pool[self.next_shape_idx];
	shape_data.push_properties(
		shape
	);

func push_shape(shape_data: FunctionBoxShape, moved_inbetween: Vector2, interp: bool) -> void:
	var shape: FunctionBoxCollisionShape2D = self.shape_pool[self.next_shape_idx];
	shape_data.push_to_shape(
		shape,
		moved_inbetween,
		interp
	);
	shape.visible = true;
	shape.disabled = false;
	self.next_shape_idx += 1;

func _exit_tree() -> void:
	self.clear_overlapped();
