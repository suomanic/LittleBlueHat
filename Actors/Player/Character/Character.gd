extends Actor

var hp = 2

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
const MS_DieState = preload("res://Actors/Player/Character/MovementState/MS_Die.gd")
const MS_AbsorbedState = preload("res://Actors/Player/Character/MovementState/MS_Absorbed.gd")
const MS_EjectedState = preload("res://Actors/Player/Character/MovementState/MS_Ejected.gd")

# preload aniamtion states
const AS_HurtState = preload("res://Actors/Player/Character/AnimState/Tier1_State/AS_Hurt.gd")
const AS_AirState = preload("res://Actors/Player/Character/AnimState/Tier1_State/AS_Air.gd")
const AS_GroundState = preload("res://Actors/Player/Character/Animstate/Tier1_State/AS_Ground.gd")
const AS_DieState = preload("res://Actors/Player/Character/AnimState/Tier1_State/AS_Die.gd")

# separate code module reference
onready var movement_module = $CharacterMovement
onready var collision_module = $CharacterCollision

# collision references
onready var ground_ray_cast_l = $RayCastL
onready var ground_ray_cast_r = $RayCastR
onready var standing_collision = $Standing_Shape
#onready var crouching_collision = $Crouching_Shape
onready var squish_collision = $SquishHitBox/CollisionShape2D
onready var trigger_collision = $Trigger/TriggerBox

# animation references
onready var movement_anim_player = $MovementAnimPlayer
onready var effect_anim_player = $EffectAnimPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet

# timer
onready var hurt_move_timer = $HurtMoveTimer

onready var anim_sprite = $AnimSpriteSheet

#particles
onready var walk_particles= $WalkParticles
onready var eject_particles = $Particles2D

onready var label = $Label
onready var label2 = $Label2

export(Curve) var absorbed_curve
export(Curve) var eject_curve

var current_absorb_bubble_global_position
var eject_angle

func _ready():
	set_as_toplevel(true)
	movement_state_machine = StateMachine.new(MS_IdleState.new(self))
	anim_state_machine = StateMachine.new(AS_GroundState.new(self))
	
	
	
	
func _physics_process(delta) -> void:
	anim_state_machine.update()
	movement_state_machine.update()
	
	
	# test only
	label.text = anim_state_machine.current_state.get_name()
	label2.text = movement_state_machine.current_state.get_name()
	
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		var str1 :String 
		str1 = collision.collider.name
		if str1.begins_with("Slime"):
			pass
		
	if movement_module.is_on_object and abs(velocity.x) > 40:
		walk_particles.set_emitting(true)
	else :
		walk_particles.set_emitting(false)

func absorbed_by_bubble(bubble_position:Vector2):
	print_debug("接受进入信号")
	movement_state_machine.change_state(MS_AbsorbedState.new(self))
	current_absorb_bubble_global_position = bubble_position
	
func ejected_from_bubble(eject_angle :float):
	print_debug("接受弹出信号")
	self.eject_angle = eject_angle
	movement_state_machine.change_state(MS_EjectedState.new(self))
	print_debug(eject_angle)
	
func tocourch_anim_end():
	movement_anim_player.play("CrouchIdle_Anim")

func hurt_anim_end():
	if hp > 0:
		if movement_module.is_on_object:
			movement_state_machine.change_state(MS_IdleState.new(self))
			anim_state_machine.change_state(AS_GroundState.new(self))
		else:
			movement_state_machine.change_state(MS_FallState.new(self))
			anim_state_machine.change_state(AS_AirState.new(self))

func die_anim_start():
	collision_module.die_collision_change()

func die_anim_end():
	get_owner().queue_free()

