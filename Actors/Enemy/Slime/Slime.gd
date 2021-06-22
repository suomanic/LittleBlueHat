extends Actor

var state_machine : StateMachine

const IdleState = preload("res://Actors/Enemy/Slime/State/1_Idle.gd")
const MoveState = preload("res://Actors/Enemy/Slime/State/1_Move.gd")

onready var anim_player = $AnimationPlayer

func _ready():
	state_machine = StateMachine.new(MoveState.new(self))

func _physics_process(delta):
	state_machine.update()
	
	velocity = move_and_slide(velocity,Vector2.UP)
	velocity.y += gravity * get_physics_process_delta_time()

	
func _move():
	velocity.x = -100
	velocity.y = -50
	
func _stop():
	velocity.x = 0
	
