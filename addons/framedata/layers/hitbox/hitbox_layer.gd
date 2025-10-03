extends FunctionBoxLayer
class_name HitBoxLayer

func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void:
	var data = local.data;
	if other_layer is HurtBoxLayer: 
		(other_layer as HurtBoxLayer).hit_by_attack.emit(data, self);
	if other_layer is HitBoxLayer: 
		(other_layer as HitBoxLayer).
