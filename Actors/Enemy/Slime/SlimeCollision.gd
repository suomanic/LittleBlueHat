extends Node

func _ready():
	pass

func ice_physic_collision():
	print_debug("yes indeed")
	owner.physic_collsion.shape.extents = Vector2(11,10.5)
	owner.physic_collsion.position = Vector2(1,-0.5)
