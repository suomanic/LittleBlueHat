extends Node

var velocity
var gravity
var is_on_object :bool

func _ready():
	velocity = owner.velocity
	gravity = owner.gravity

func _physics_process(delta):
	apply_gravity()
	velocity = owner.move_and_slide(velocity,Vector2.UP)
	velocity.y += gravity * delta
	
	
func apply_gravity():
	if owner.r_ground_ray_cast.is_colliding() or owner.l_ground_ray_cast.is_colliding() :
		gravity = 0
		is_on_object = true
	else:
		gravity = 300
		is_on_object = false

#Animation call function	
func normal_move():
	pass
	
func fire_move():
		pass

func gravity():
	pass

func move_finish():
	pass
	
func move_start():
	pass
