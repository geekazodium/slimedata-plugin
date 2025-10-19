extends CharacterBody2D

func _physics_process(delta: float) -> void:
	self.move_and_slide();
	self.velocity += self.get_gravity() * delta + -2 * self.velocity * delta;
