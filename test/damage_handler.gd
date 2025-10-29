extends Node

func _on_hurt_box_hit_by_attack(data: HitBoxData, _other_layer: FunctionBoxLayer) -> void:
	var parent = self.get_parent() as CharacterBody2D;
	parent.velocity -= parent.velocity * data.launch_decel_fac;
	parent.velocity += data.launch_vec;
	HitStopTimer.set_hitstop(data.hitstop);
