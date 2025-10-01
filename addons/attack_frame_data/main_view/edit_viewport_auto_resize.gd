@tool
extends SubViewport
class_name AutoResizingViewport

@export var size_source: Control;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.size = self.size_source.size
