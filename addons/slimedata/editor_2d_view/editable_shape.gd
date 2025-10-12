@tool
extends FunctionBoxCollisionShape2D
class_name EditableShape2D

func move_by(vec: Vector2) -> void:
	ToolSpaceUtils.move_shape(self.shape_src, vec);

func add_to_radius(delta_r: float) -> void:
	ToolSpaceUtils.add_shape_scale(self.shape_src, delta_r);

func push_radius_tmp(radius: float) -> void:
	var start_rad: float = self.shape_src.radius;
	self.shape_src.radius = max(radius,0);
	self.shape_src.push_to_shape(self, Vector2.ZERO, false);
	self.shape_src.radius = start_rad;
