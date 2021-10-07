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
	
	owner.set_collision_layer_bit(5,true)
	owner.set_collision_layer_bit(2,false)
	
	owner.squish_collsion.set_disabled(true)
	

func change_to_fire_collision_box() :
	owner.f_ray_cast.position.y = -20
	set_shape(RectangleShape2D.new())
	shape.extents = Vector2(10,8)
	
	position = Vector2(1,2)
	
	#启用转向
	owner.f_ray_cast.set_enabled(true)
	owner.b_ray_cast.set_enabled(true)
	
	owner.player_detectshape.set_deferred("disabled",false)
	owner.squish_collsion.set_deferred("disabled",false)
	
	owner.set_collision_layer_bit(5,false)
	owner.set_collision_layer_bit(2,true)
	
	

func change_to_normal_collision_box():
	owner.f_ray_cast.position.y = 0
	set_shape(RectangleShape2D.new())
	shape.extents = Vector2(10,8)
	
	position = Vector2(1,2)
	
	#启用转向
	owner.f_ray_cast.set_enabled(true)
	owner.b_ray_cast.set_enabled(true)

	owner.player_detectshape.set_deferred("disabled",true)
	owner.squish_collsion.set_deferred("disabled",false)
	
	owner.set_collision_layer_bit(5,false)
	owner.set_collision_layer_bit(2,true)
	

func disable_squish_damage_collision():
	owner.squish_collsion.set_deferred("disabled",true)
	
	owner.set_collision_layer_bit(5,false)
	owner.set_collision_layer_bit(2,true)
	
	owner.set_collision_mask_bit(5,false)
	owner.set_collision_mask_bit(1,true)
	
	owner.SDM_Timer.set_wait_time(0.1)
	owner.SDM_Timer.start()
	pass

func enable_squish_damage_collision():
	owner.SDM_Timer.stop()
	
	
	owner.set_collision_layer_bit(5,false)
	owner.set_collision_layer_bit(2,true)
	
	owner.set_collision_mask_bit(5,true)
	owner.set_collision_mask_bit(1,true)
	
