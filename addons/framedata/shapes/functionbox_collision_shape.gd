extends CollisionShape2D
class_name FunctionBoxCollisionShape2D

var owned_capsule_shape: CapsuleShape2D;

func _ready() -> void:
	self.owned_capsule_shape = CapsuleShape2D.new();
	self.shape = self.owned_capsule_shape;

func push_circle(pos: Vector2, radius: float) -> void:
	self.position = pos;
	self.rotation = 0;
	self.owned_capsule_shape.radius = radius;
	self.owned_capsule_shape.height = radius * 2;

func push_capsule(position1: Vector2, position2: Vector2, radius: float) -> void:
	## slight optimization: differece value is reused in many instances here
	var diff = position2 - position1;
	## lerping between a, b, t is simplified to a + t(b - a)
	self.position = position1 + diff * .5;
	## angle of shape is easily determined (b - a).angle() should be correct
	self.rotation = Vector2(-diff.y, diff.x).angle();
	## length of capsule is radius * 2 + |b - a|
	self.owned_capsule_shape.height = diff.length() + radius * 2;
	self.owned_capsule_shape.radius = radius;
