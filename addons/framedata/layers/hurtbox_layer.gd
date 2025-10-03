extends FunctionBoxLayer
class_name HurtBoxLayer

signal hit_by_attack(data: HitBoxData, other_layer: FunctionBoxLayer);

func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void:
	pass
