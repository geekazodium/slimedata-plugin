extends Node

func _on_hurt_box_hit_by_attack(data: HitBoxData, other_layer: FunctionBoxLayer) -> void:
	print("hit");
	$"../".velocity += data.launch_vec; # Replace with function body.
