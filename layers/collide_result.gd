extends Object
class_name OverlapResult

var _src: FunctionBoxShape; ## nullable
var _hit: FunctionBoxShape; ## nullable
var handled: bool = false;

static var _dummy_handled: OverlapResult = _new_dummy_result();

static func get_dummy() -> OverlapResult:
	return _dummy_handled;

static func _new_dummy_result() -> OverlapResult:
	var dummy: OverlapResult = new_result(null,null);
	dummy.handled = true;
	return dummy;

static func new_result(src: FunctionBoxShape, hit: FunctionBoxShape) -> OverlapResult:
	var result: OverlapResult = OverlapResult.new();
	result._src = src;
	result._hit = hit;
	return result;

func attempt_push_new(src: FunctionBoxCollisionShape2D, hit: FunctionBoxCollisionShape2D) -> void:
	if self.has_priority_over(src,hit):
		print("%s: collision dropped: higher priority value present" % [self]);
		return;
	self._src = src.shape_src;
	self._hit = hit.shape_src;

func has_priority_over(src: FunctionBoxCollisionShape2D, hit: FunctionBoxCollisionShape2D) -> bool:
	if self.handled:
		return true;
	if self._src.priority > src.priority: 
		return true;
	if self._src.priority == src.priority:
		if self._hit.priority >= hit.priority:
			return true;
	return false;

func get_src() -> FunctionBoxShape:
	return self._src;

func get_hit() -> FunctionBoxShape:
	return self._hit;
