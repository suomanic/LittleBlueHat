extends Actor

var direction: = Vector2()

# movement state machine
var movement_state_machine : StateMachine

# animation state machine
var anim_state_machine : StateMachine

# preload movement states
const MS_IdleState = preload("res://Actors/Player/Movementstate/Idle.gd")
const MS_RunState = preload("res://Actors/Player/Movementstate/Run.gd")
const MS_FallState = preload("res://Actors/Player/Movementstate/Fall.gd")
const MS_DoubleJumpState = preload("res://Actors/Player/Movementstate/DoubleJump.gd")
const MS_CrouchState = preload("res://Actors/Player/Movementstate/Crouch.gd")
const MS_UpState = preload("res://Actors/Player/Movementstate/Up.gd")

# preload aniamtion states
const AS_AirState = preload("res://Actors/Player/Animstate/Air.gd")
const AS_GroundState = preload("res://Actors/Player/Animstate/Ground.gd")

onready var input_module = get_node("PlayerInput")
onready var movement_module = get_node("PlayerMovement")

onready var standing_collision = $Standing_Shape
onready var crouching_collision = $Crouching_Shape

onready var animation_player = $AnimationPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet

func _ready():
	
	movement_state_machine = StateMachine.new(MS_IdleState.new(self))
	anim_state_machine = StateMachine.new(AS_GroundState.new(self))

func _physics_process(delta) -> void:
	
	anim_state_machine.update()
	movement_state_machine.update()
		
	direction = input_module.get_direction()
	
	animation_control()
	
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
	
func tocourch_anim_end():
	animation_player.play("CrouchIdle_Anim")
