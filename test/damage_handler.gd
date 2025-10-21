extends Node

func _on_hurt_box_hit_by_attack(data: HitBoxData, _other_layer: FunctionBoxLayer) -> void:
	print("hit");
	
	$"../".velocity -= $"../".velocity * data.launch_decel_fac;
	$"../".velocity += data.launch_vec;
	HitStopTimer.set_hitstop(data.hitstop);
