@tool
extends FunctionBoxLayer
class_name EditableFunctionBoxLayer

static var selected_color: Color = Color(0xd28100d8);
static var selected_blend_fac: float = .6;

static var unselected_color: Color = Color(0x7878789c);
static var unselected_blend_fac: float = .6;

var _selected_shapes: Array[EditableShape2D] = [];
var linked_provider: FrameDataProviderTool;

var push_count: int = 0;

signal shape_input(event: InputEvent, shape: EditableShape2D, layer: EditableFunctionBoxLayer);

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.allocate_shape_pool(10);
	self.input_pickable = true;
	self.monitoring = true;
	self.linked_provider = self.get_parent() as FrameDataProviderTool;
	self.linked_provider.clear_selection.connect(self.clear_selected);
	self.set_process(true);
	self.process_mode = Node.PROCESS_MODE_ALWAYS;
	
func clear_selected() -> void:
	for shape: EditableShape2D in self._selected_shapes:
		self._shape_unselected(shape);
	self._selected_shapes.clear();

func unselect_shape(shape: EditableShape2D) -> void:
	self._selected_shapes.remove_at(self._selected_shapes.find(shape));
	self._shape_unselected(shape);

func select_shape(shape: EditableShape2D) -> void:
	self._selected_shapes.append(shape);
	self._shape_selected(shape);

func get_selected_shapes() -> Array[EditableShape2D]:
	return self._selected_shapes;

func _shape_selected(shape: EditableShape2D) -> void:
	EditorInterface.get_inspector().edit(shape.shape_src);
	shape.debug_color = self.default_debug_color.lerp(selected_color,selected_blend_fac);

func _shape_unselected(shape: EditableShape2D) -> void:
	self._reset_shape_color(shape);

func _reset_shape_color(shape: FunctionBoxCollisionShape2D) -> void:
	shape.debug_color = self.default_debug_color.lerp(unselected_color,unselected_blend_fac);

@warning_ignore("unused_parameter")
func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void:
	pass

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	var shape: EditableShape2D = self.shape_owner_get_owner(self.shape_find_owner(shape_idx));
	self.shape_input.emit(event, shape, self);

func is_shape_selected(shape: EditableShape2D) -> bool:
	return self._selected_shapes.has(shape);

func clear() -> void:
	super.clear();
	self.push_count = 0;

## call this to push properties to shape before pushing actual shape.
func push_properties(shape_data: FunctionBoxShape) -> void:
	if self.push_count >= self.shape_pool.size():
		self._increment_pool_size();
	var shape: EditableShape2D = self.shape_pool[self.push_count];
	shape_data.push_properties(
		shape
	);
	
func push_shape(shape_data: FunctionBoxShape, interp: bool, transform_matrix: Vector4) -> void:
	if self.push_count >= self.shape_pool.size():
		self._increment_pool_size();
	var shape: EditableShape2D = self.shape_pool[self.push_count];
	self.push_count += 1;
	shape_data.push_to_shape(
		shape,
		Vector2.ZERO,
		interp,
		transform_matrix
	);
	shape.visible = true;
	shape.disabled = false;

func _increment_pool_size() -> void:
	var instance: EditableShape2D = EditableShape2D.new();
	self.shape_pool.append(instance);
	self.add_child(instance);
	self._reset_shape_color(instance);
