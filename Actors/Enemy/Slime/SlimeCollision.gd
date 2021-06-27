extends Node

func _ready():
	pass

func change_ice_collision():
	owner.physic_collsion.set_shape(RectangleShape2D.new())
	owner.physic_collsion.shape.extents = Vector2(11,10.5)
	
	if owner.is_moving_left:
		owner.physic_collsion.position = Vector2(1,-0.5)
	else:
		owner.physic_collsion.position = Vector2(-1,-0.5)
	owner.set_collision_mask_bit(0,true)
	
	#禁用转向
	owner.f_ray_cast.set_enabled(false)
	owner.b_ray_cast.set_enabled(false)

func ItoN_collision_change():
	owner.physic_collsion.set_shape(CapsuleShape2D.new())
	owner.physic_collsion.shape.radius = 8
	owner.physic_collsion.shape.height = 0
	
	owner.physic_collsion.position = Vector2(0,2)
	owner.set_collision_mask_bit(0,false)
	
	#禁用转向
	owner.f_ray_cast.set_enabled(true)
	owner.b_ray_cast.set_enabled(true)
	
