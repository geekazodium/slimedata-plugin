extends FunctionBoxLayer
class_name HurtBoxLayer

@warning_ignore("unused_signal")
signal hit_by_attack(data: HitBoxData, other_layer: FunctionBoxLayer);

@warning_ignore("unused_parameter")
func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void:
	pass
