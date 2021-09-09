extends Node

var velocity
var gravity
var deceleration

var is_on_object :bool
var is_normal_move
var is_fire_move

var is_hurt_move_left := true
var is_moving_left := true
var is_moving_finished := false

func _ready():
	velocity = owner.velocity
	gravity = owner.gravity
	deceleration = owner.deceleration

func _physics_process(delta):
	apply_gravity()
	cal_velocity(delta)
	
func apply_gravity():
	if owner.r_ground_ray_cast.is_colliding() or owner.l_ground_ray_cast.is_colliding() :
		gravity -= 50
		gravity = max(0,gravity)
		
		is_on_object = true
	else:
		gravity = 600
		is_on_object = false

func cal_velocity(delta):
	velocity = owner.move_and_slide(velocity,Vector2.UP)
	velocity.y += gravity * delta
	
	if velocity.x > 0:
		velocity.x = max(velocity.x - owner.deceleration,0)
	elif velocity.x < 0:
		velocity.x = min(velocity.x + owner.deceleration,0)
	
func N_move():
	if is_normal_move:
		if is_moving_left:
			velocity.x = -50
		else:
			velocity.x = 50
	else:
		velocity.x = 0 
		
func F_move():
	if is_fire_move:
		if is_moving_left:
			velocity.x = -100
		else:
			velocity.x = 100
			
	else:
		velocity.x = 0

#被打
func hurt_move():
	if is_hurt_move_left:
		velocity = Vector2(0,0)
	else:
		velocity = Vector2(0,0)
		
	
#Animation call function	
func normal_move():
	is_normal_move = true
	is_moving_finished = false
	if is_moving_left:
		velocity = Vector2(-50 , -100) 
	else :
		velocity = Vector2(50 , -100) 
	pass
	
func fire_move():
	is_fire_move = true
	is_moving_finished = false
	if is_moving_left:
		velocity = Vector2(-100 , -220) 
	else :
		velocity = Vector2(100 , -220) 
	pass

func move_finish():
	is_normal_move = false
	is_fire_move = false
	is_moving_finished = true
