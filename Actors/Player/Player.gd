extends Actor

var direction: = Vector2()

var state_machine : StateMachine

const MS_IdleState = preload("res://Actors/Player/Movementstate/Idle.gd")
const MS_RunState = preload("res://Actors/Player/Movementstate/Run.gd")
const MS_FallState = preload("res://Actors/Player/Movementstate/Fall.gd")
const MS_DoubleJumpState = preload("res://Actors/Player/Movementstate/DoubleJump.gd")
const MS_CrouchState = preload("res://Actors/Player/Movementstate/Crouch.gd")
const MS_UpState = preload("res://Actors/Player/Movementstate/Up.gd")

const AS_AirState = preload("res://Actors/Player/Animstate/Air.gd")
const AS_Ground = preload("res://Actors/Player/Animstate/Ground.gd")

onready var input_module = get_node("PlayerInput")
onready var movement_module = get_node("PlayerMovement")

onready var standing_collision = $Standing_Shape
onready var crouching_collision = $Crouching_Shape

onready var animation_player = $AnimationPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet


func _ready():
	state_machine = StateMachine.new(MS_IdleState.new(self))

func _physics_process(delta) -> void:
	state_machine.update()
		
	direction = input_module.get_direction()
	
	animation_control()
	velocity = move_and_slide(velocity,Vector2.UP)
	
		
	if is_on_floor() and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)

func animation_control():
	if direction.x > 0 :
		$AnimSpriteSheet.scale.x = 1
		$Particles2D.scale.x = 1
		$Particles2D.set_position(Vector2(-4,12))
	elif direction.x < 0 :
		$AnimSpriteSheet.scale.x = -1
		$Particles2D.scale.x = -1
		$Particles2D.set_position(Vector2(4,12))
	



func _spring_area_entered(area: Area2D) -> void:
	velocity.y = -350
	movement_module.jump_count = 1
