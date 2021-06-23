extends Actor

var state_machine : StateMachine
var is_moving_left := true
var moving_finished = false

const IdleState = preload("res://Actors/Enemy/Slime/State/1_Idle.gd")
const MoveState = preload("res://Actors/Enemy/Slime/State/1_Move.gd")

onready var anim_player = $AnimationPlayer
onready var f_ray_cast = $FrontRayCast
onready var b_ray_cast = $BackRayCast

func _ready():
	state_machine = StateMachine.new(MoveState.new(self))

func _physics_process(delta):
	state_machine.update()
	
	_turn_around()
	
	velocity = move_and_slide(velocity,Vector2.UP)
	velocity.y += gravity * get_physics_process_delta_time()

	
func _move():
	if is_moving_left:
		velocity.x = -120
	else:
		velocity.x = 120
	velocity.y = -50
	
func _stop():
	velocity.x = 0
	
func _turn_around():
	if f_ray_cast.is_colliding() and moving_finished and !b_ray_cast.is_colliding():
		is_moving_left = !is_moving_left
		scale.x = -scale.x
	pass
	
