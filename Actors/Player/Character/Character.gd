extends Actor

# movement state machine
var movement_state_machine : StateMachine

# animation state machine
var anim_state_machine : StateMachine

# preload movement states
const MS_IdleState = preload("res://Actors/Player/Character/MovementState/Idle.gd")
const MS_RunState = preload("res://Actors/Player/Character/Movementstate/Run.gd")
const MS_FallState = preload("res://Actors/Player/Character/Movementstate/Fall.gd")
const MS_DoubleJumpState = preload("res://Actors/Player/Character/Movementstate/DoubleJump.gd")
const MS_CrouchState = preload("res://Actors/Player/Character/Movementstate/Crouch.gd")
const MS_UpState = preload("res://Actors/Player/Character/Movementstate/Up.gd")

# preload aniamtion states
const AS_AirState = preload("res://Actors/Player/Character/Animstate/Air.gd")
const AS_GroundState = preload("res://Actors/Player/Character/Animstate/Ground.gd")

onready var movement_module = $CharacterMovement
onready var collision_module = $CharacterCollision

onready var standing_collision = $Standing_Shape
#onready var crouching_collision = $Crouching_Shape

onready var animation_player = $AnimationPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet

func _ready():
	
	movement_state_machine = StateMachine.new(MS_IdleState.new(self))
	anim_state_machine = StateMachine.new(AS_GroundState.new(self))
	
	owner.get_node("Weapon").get_node("FireSword").set_physics_process(false)
	owner.get_node("Weapon").get_node("FireSword").set_process(false)
	owner.get_node("Weapon").get_node("FireSword").set_visible(false)

var change_count = 0

func _physics_process(delta) -> void:
	
	anim_state_machine.update()
	movement_state_machine.update()
	animation_control()
	
	if owner.input_module.is_change_element_just_pressed:
		if change_count % 2 == 0:
			print_debug("change to fire sword")
			owner.get_node("Weapon").get_node("FireSword").set_physics_process(true)
			owner.get_node("Weapon").get_node("FireSword").set_visible(true)
			owner.get_node("Weapon").get_node("IceSword").set_physics_process(false)
			owner.get_node("Weapon").get_node("IceSword").set_visible(false)
		else:
			print_debug("change to ice sword")
			owner.get_node("Weapon").get_node("FireSword").set_physics_process(false)
			owner.get_node("Weapon").get_node("FireSword").set_visible(false)
			owner.get_node("Weapon").get_node("IceSword").set_physics_process(true)
			owner.get_node("Weapon").get_node("IceSword").set_visible(true)
		change_count += 1
		
	if is_on_floor() and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)

func animation_control():
	if owner.input_module.get_direction().x > 0 :
		$AnimSpriteSheet.scale.x = 1
		$Particles2D.scale.x = 1
		$Particles2D.set_position(Vector2(-4,12))
	elif owner.input_module.get_direction().x < 0 :
		$AnimSpriteSheet.scale.x = -1
		$Particles2D.scale.x = -1
		$Particles2D.set_position(Vector2(4,12))
	
func tocourch_anim_end():
	animation_player.play("CrouchIdle_Anim")
