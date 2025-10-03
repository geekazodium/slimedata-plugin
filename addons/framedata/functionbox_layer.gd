extends Area2D
class_name FunctionBoxLayer

var shape_pool: Array[FunctionBoxCollisionShape2D] = [];
var next_shape_idx: int = 0;

var default_debug_color: Color: 
	set = _set_debug_col;

func _set_debug_col(color: Color):
	default_debug_color = color;
	for instance in self.shape_pool:
		instance.debug_color = default_debug_color;

func _ready() -> void:
	self.allocate_shape_pool(10);

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
