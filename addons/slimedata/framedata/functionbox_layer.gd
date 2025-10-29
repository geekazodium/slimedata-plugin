@abstract
extends Area2D
class_name FunctionBoxLayer

static var ignore_layer_array: Array[FunctionBoxShape] = []; 

var shape_pool: Array[FunctionBoxCollisionShape2D] = [];

var default_debug_color: Color: 
	set = _set_debug_col;

var overlapped: Dictionary[FunctionBoxLayer, Array] = {};

var alloc_max_id: int = 20;

func _set_debug_col(color: Color) -> void:
	default_debug_color = color;
	for instance in self.shape_pool:
		self._reset_shape_color(instance);

func clear_overlapped() -> void:
	for key in self.overlapped.keys():
		var res_hit_results: Array = self.overlapped[key]; ##array: OverlapResult
		for i: OverlapResult in res_hit_results:
			if i == null:
				continue;
			if i == OverlapResult.get_dummy():
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
	print("%s: collision signal registered! %s" % [self, area]);
	var other_func_box_layer: FunctionBoxLayer = area as FunctionBoxLayer;
	if other_func_box_layer == null:
		print("%s: collision dropped: invalid other layer" % [self]);
		return;
	var layer_overlaps: Array = self.get_overlap_for_layer(other_func_box_layer);
	if layer_overlaps == ignore_layer_array:
		print("%s: collision dropped: ignoring other layer %s" % [self, other_func_box_layer]);
		return;
	
	var local_shape_owner = shape_find_owner(local_shape_index);
	var local_shape: FunctionBoxCollisionShape2D = shape_owner_get_owner(local_shape_owner) as FunctionBoxCollisionShape2D;
	if local_shape == null: 
		print("%s: collision dropped: null local shape reference" % [self]);
		return;
	
	var other_shape_owner = area.shape_find_owner(area_shape_index);
	var other_shape: FunctionBoxCollisionShape2D = area.shape_owner_get_owner(other_shape_owner) as FunctionBoxCollisionShape2D;	
	if other_shape == null:
		print("%s: collision dropped: null other shape reference" % [self]);
		return;
	
	var result: OverlapResult = layer_overlaps[local_shape.key];
	if result != null:
		result.attempt_push_new(local_shape, other_shape);
	else:
		layer_overlaps[local_shape.key] = OverlapResult.new_result(local_shape.shape_src, other_shape.shape_src);

func set_layer_as_handled(other_layer: FunctionBoxLayer) -> void:
	self.overlapped.set(other_layer, ignore_layer_array);

func set_as_handled(other_layer: FunctionBoxLayer, index: int) -> void:
	var layer_overlaps: Array = self.get_overlap_for_layer(other_layer);
	if layer_overlaps[index] == null:
		layer_overlaps[index] = OverlapResult.get_dummy();
	else:
		layer_overlaps[index].handled = true;

func _physics_process(delta: float) -> void:
	#hitting a large amount of enemies with a single attack could potentially cause performance issues
	for key in self.overlapped.keys():
		var res_hit_results: Array = self.overlapped[key]; ##array: OverlapResult
		for i: OverlapResult in res_hit_results:
			if i == null:
				continue;
			if i.handled:
				continue; ## note to self: this should be a continue statement
						## I may have forgotten that and that's gotta be peak 
						## embarrassing
			print("%s: collision handled: %s" % [self, key]);
			self._process_overlap(key,i.get_src(), i.get_hit());
			i.handled = true; 

@abstract
func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void;

func get_framedata_provider() -> FrameDataProvider:
	return self.get_parent() as FrameDataProvider;

func allocate_shape_pool(size: int) -> void:
	for i in range(size):
		self._increment_pool_size();
	self.clear();

func _increment_pool_size() -> void:
	var instance: FunctionBoxCollisionShape2D = FunctionBoxCollisionShape2D.new();
	self.shape_pool.append(instance);
	self.add_child(instance);
	self._reset_shape_color(instance);

func _reset_shape_color(shape: FunctionBoxCollisionShape2D) -> void:
	shape.debug_color = self.default_debug_color;

func clear() -> void:
	for shape in shape_pool:
		self._remove_shape(shape);

func _remove_shape(shape: FunctionBoxCollisionShape2D) -> void:
	shape.visible = false;
	shape.disabled = true;

## call this to push properties to shape before pushing actual shape.
func push_properties(shape_data: FunctionBoxShape) -> void:
	var shape: FunctionBoxCollisionShape2D = self.shape_pool[shape_data.reserved_index];
	shape_data.push_properties(
		shape
	);

func push_shape(shape_data: FunctionBoxShape, interp: bool) -> void:
	var shape: FunctionBoxCollisionShape2D = self.shape_pool[shape_data.reserved_index];
	shape_data.push_to_shape(
		shape,
		Vector2.ZERO,
		interp
	);
	shape.visible = true;
	shape.disabled = false;

func _exit_tree() -> void:
	self.clear_overlapped();
