extends CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_to_ice_collision_box() :
	set_shape(RectangleShape2D.new())
	shape.extents = Vector2(11,10.5)
	
	if owner.is_moving_left:
		position = Vector2(1,-0.5)
	else:
		position = Vector2(-1,-0.5)
	owner.set_collision_mask_bit(0,true)
	
	#禁用转向
	owner.f_ray_cast.set_enabled(false)
	owner.b_ray_cast.set_enabled(false)
	

func change_to_fire_collision_box() :
	owner.f_ray_cast.position.y = -20
	set_shape(CapsuleShape2D.new())
	shape.radius = 8
	shape.height = 0
	
	position = Vector2(0,2)
	owner.set_collision_mask_bit(0,false)
	pass

func change_to_normal_collision_box():
	owner.f_ray_cast.position.y = 0
	set_shape(CapsuleShape2D.new())
	shape.radius = 8
	shape.height = 0
	
	position = Vector2(0,2)
	owner.set_collision_mask_bit(0,false)
