extends CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func change_to_ice_collision_box() :
	set_shape(RectangleShape2D.new())
	shape.extents = Vector2(11,10.5)
	
	position = Vector2(1,-0.5)
	
	#禁用转向
	owner.f_ray_cast.set_enabled(false)
	owner.b_ray_cast.set_enabled(false)
	
	owner.set_collision_layer(00000000000000100000) 
	
	owner.squish_collsion.set_disabled(true)
	

func change_to_fire_collision_box() :
	owner.f_ray_cast.position.y = -20
	set_shape(RectangleShape2D.new())
	shape.extents = Vector2(10,8)
	
	position = Vector2(1,2)
	
	#启用转向
	owner.f_ray_cast.set_enabled(true)
	owner.b_ray_cast.set_enabled(true)
	
	owner.player_detectshape.disabled = false
	
	owner.set_collision_layer(00000000000000000000) 
	
	owner.squish_collsion.set_disabled(false)

func change_to_normal_collision_box():
	print_debug(owner.get_collision_mask_bit(0))
	owner.f_ray_cast.position.y = 0
	set_shape(RectangleShape2D.new())
	shape.extents = Vector2(10,8)
	
	position = Vector2(1,2)
	
	#启用转向
	owner.f_ray_cast.set_enabled(true)
	owner.b_ray_cast.set_enabled(true)
	
	owner.player_detectshape.disabled = true
	
	owner.set_collision_layer(00000000000000000000) 
	
	owner.squish_collsion.set_disabled(false)

func disable_squish_damage_collision():
	owner.squish_collsion.set_disabled(true)
	owner.set_collision_layer(00000000000000000000) 
	owner.set_collision_mask(00000000000000000010) 
	owner.switch_collision_timer.set_wait_time(0.1)
	owner.switch_collision_timer.start()
	pass

func enable_squish_damage_collision():
	owner.switch_collision_timer.stop()
	owner.set_collision_layer(00000000000000000000) 
	owner.set_collision_mask(00000000000000100010) 
	owner.squish_collsion.set_disabled(false)
	
