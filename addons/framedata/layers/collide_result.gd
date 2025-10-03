extends Object
class_name OverlapResult

var src: FunctionBoxShape;
var hit: FunctionBoxShape;
var handled: bool = false;

static func new_result(src: FunctionBoxShape, hit: FunctionBoxShape) -> OverlapResult:
	var result: OverlapResult = OverlapResult.new();
	result.src = src;
	result.hit = hit;
	return result;
