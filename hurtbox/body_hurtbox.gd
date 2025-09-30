extends Area2D
class_name BodyHurtbox

func _ready() -> void:
	self.area_shape_entered.connect(self._area_shape_entered);

@warning_ignore("unused_parameter")
func _area_shape_entered(
		area_rid: RID, 
		area: Area2D, 
		area_shape_index: int, 
		local_shape_index: int
	) -> void:
	pass

func hit():
	$"../".velocity += Vector2.UP * 1000;
