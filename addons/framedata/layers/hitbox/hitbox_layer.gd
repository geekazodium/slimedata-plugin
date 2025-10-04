extends FunctionBoxLayer
class_name HitBoxLayer

func _process_overlap(other_layer: FunctionBoxLayer,local: FunctionBoxShape, other: FunctionBoxShape) -> void:
	var data = local.data;
	if other_layer is HurtBoxLayer: 
		if other_layer.get_framedata_provider() == self.get_framedata_provider():
			return;
		(other_layer as HurtBoxLayer).hit_by_attack.emit(data, self);
	if other_layer is HitBoxLayer: 
		var other_hurtbox_l = (other_layer as HitBoxLayer).get_framedata_provider().get_layer("HurtBoxLayer");
		self.set_layer_as_handled(other_hurtbox_l);
