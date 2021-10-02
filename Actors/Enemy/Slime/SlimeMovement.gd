extends Node

var velocity
var gravity
var deceleration

var is_normal_move
var is_fire_move

var is_hurt_move_left := true
var is_moving_left := true
var is_moving_finished := false

var is_on_object := false

func _ready():
	velocity = owner.velocity
	gravity = owner.gravity
	deceleration = owner.deceleration

func _physics_process(delta):
	apply_gravity()
	calc_velocity(delta)
	
func apply_gravity():
	velocity.y = min(velocity.y,150)
	
	if owner.r_ground_ray_cast.is_colliding() or owner.l_ground_ray_cast.is_colliding() :
		is_on_object = true
		gravity -= 50
		gravity = max(0,gravity)
	else:
		is_on_object = false
		gravity = 600

func calc_velocity(delta):
	if ! (owner.element_state == "Ice" and gravity <= 10):
		velocity = owner.move_and_slide(velocity,Vector2.UP)
	velocity.y += gravity * delta
	
	if velocity.x > 0:
		velocity.x = max(velocity.x - owner.deceleration,0)
	elif velocity.x < 0:
		velocity.x = min(velocity.x + owner.deceleration,0)


func N_move():
	if velocity.y > 0 and velocity.x == 0:
		velocity.x = 0
	else:
		if is_normal_move:
			if is_moving_left:
				velocity.x = -75
			else:
				velocity.x = 75
		else:
			velocity.x = 0 
	
func F_move():
	if velocity.y > 0 and velocity.x == 0:
		velocity.x = 0
	else:
		if is_fire_move or (is_moving_finished and !is_on_object):
			if is_moving_left:
				velocity.x = -100
			else:
				velocity.x = 100
		elif !is_fire_move and is_on_object:
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
	velocity.y = -125
	
func fire_move():
	is_fire_move = true
	is_moving_finished = false
	velocity.y = -250

func squish_damage_move(will_go_left):
	if will_go_left:
		velocity = Vector2(300 , -100) 
	else :
		velocity = Vector2(-300 , -100) 
	pass

func move_finish():
	is_normal_move = false
	is_fire_move = false
	is_moving_finished = true
