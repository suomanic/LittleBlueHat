extends Actor

var is_facing_left
var pre_facing = false #false means facing right

# movement state machine
var movement_state_machine : StateMachine

# animation state machine
var anim_state_machine : StateMachine

# preload movement states
const MS_IdleState = preload("res://Actors/Player/Character/MovementState/MS_Idle.gd")
const MS_RunState = preload("res://Actors/Player/Character/Movementstate/MS_Run.gd")
const MS_FallState = preload("res://Actors/Player/Character/Movementstate/MS_Fall.gd")
const MS_DoubleJumpState = preload("res://Actors/Player/Character/Movementstate/MS_DoubleJump.gd")
const MS_CrouchState = preload("res://Actors/Player/Character/Movementstate/MS_Crouch.gd")
const MS_UpState = preload("res://Actors/Player/Character/Movementstate/MS_Up.gd")
const MS_HurtState = preload("res://Actors/Player/Character/MovementState/MS_Hurt.gd")

# preload aniamtion states

const AS_HurtState = preload("res://Actors/Player/Character/AnimState/Tier1_State/AS_Hurt.gd")
const AS_AirState = preload("res://Actors/Player/Character/AnimState/Tier1_State/AS_Air.gd")
const AS_GroundState = preload("res://Actors/Player/Character/Animstate/Tier1_State/AS_Ground.gd")

onready var movement_module = $CharacterMovement
onready var collision_module = $CharacterCollision

onready var ground_ray_cast_l = $RayCastL
onready var ground_ray_cast_r = $RayCastR
onready var standing_collision = $Standing_Shape
#onready var crouching_collision = $Crouching_Shape
onready var squish_collision = $SquishHitBox/CollisionShape2D

onready var animation_player = $AnimationPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet

onready var hurt_move_timer = $HurtMoveTimer

func _ready():
	movement_state_machine = StateMachine.new(MS_IdleState.new(self))
	anim_state_machine = StateMachine.new(AS_GroundState.new(self))
	
func _physics_process(delta) -> void:
	anim_state_machine.update()
	movement_state_machine.update()
	is_facing_left = facing()
	print_debug(is_facing_left)
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var str1 :String 
		str1 = collision.collider.name
		if str1.begins_with("Slime"):
			pass
		
	if is_on_floor() and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)

func facing() -> bool : #the boolean means is character facing left,true means left
	
	if owner.input_module.get_direction().x > 0 :
		$AnimSpriteSheet.scale.x = 1
		$Particles2D.scale.x = 1
		$Particles2D.set_position(Vector2(-4,12))
		pre_facing = false
		return false
	elif owner.input_module.get_direction().x < 0 :
		$AnimSpriteSheet.scale.x = -1
		$Particles2D.scale.x = -1
		$Particles2D.set_position(Vector2(4,12))
		pre_facing = true
		return true
	else:
		return pre_facing
	
func tocourch_anim_end():
	animation_player.play("CrouchIdle_Anim")

func hurt_anim_end():
	if is_on_floor() or movement_module.is_on_object:
		movement_state_machine.change_state(MS_IdleState.new(self))
		anim_state_machine.change_state(AS_GroundState.new(self))
	else:
		movement_state_machine.change_state(MS_FallState.new(self))
		anim_state_machine.change_state(AS_AirState.new(self))



