@tool
extends FunctionBoxCollisionShape2D
class_name EditableShape2D

func move_by(vec: Vector2) -> void:
	ToolSpaceUtils.move_shape(self.shape_src, vec);
