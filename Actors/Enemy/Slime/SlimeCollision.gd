extends Node

func _ready():
	pass

func ice_physic_collision():
	owner.physic_collsion_shape.extents = Vector2(11,10.5)
	owner.get_node("PhysicCollision").position = Vector2(1,-0.5)
