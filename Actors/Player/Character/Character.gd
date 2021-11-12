extends Actor

var hp = 2

# movement state machine
onready var movement_state_machine: StateMachine = get_node("CharacterMovementStateMachine")

# animation state machine
onready var anim_state_machine : StateMachine = get_node("CharacterAnimStateMachine")

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

onready var state_machine_status : Dictionary = {
	movement_state = "",
	anim_state = "" # = anim_state_machine.current_state.get_name()
}

export var rpc_sync_state_interval = 0
var rpc_sync_state_interval_count = rpc_sync_state_interval

func _ready():
	set_as_toplevel(true)
	if (self.get_tree().has_network_peer() and self.is_network_master()) or !self.get_tree().has_network_peer():
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
	
	# 如果处于联机模式下且自己是master节点
	if self.get_tree().has_network_peer() and self.is_network_master():
		var new_state_machine_status:Dictionary = {}
		
		var curr_movement_state_name: String = ""
		var curr_anim_state_name: String = ""
		
		if movement_state_machine.current_state != null:
			curr_movement_state_name = movement_state_machine.current_state.get_name()
		if anim_state_machine.current_state != null:
			curr_anim_state_name = anim_state_machine.current_state.get_name()
		
		if curr_movement_state_name != state_machine_status.movement_state:
			state_machine_status.movement_state = curr_movement_state_name
			new_state_machine_status.movement_state = curr_movement_state_name
		if curr_anim_state_name != state_machine_status.anim_state :
			state_machine_status.anim_state = curr_anim_state_name
			new_state_machine_status.anim_state = curr_anim_state_name
		
		if !new_state_machine_status.empty():
			if(rpc_sync_state_interval_count<=0):
				self.rpc_unreliable('_change_state_machine_status', new_state_machine_status)
				rpc_sync_state_interval_count = rpc_sync_state_interval
			else:
				rpc_sync_state_interval_count-=1

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

puppet func _change_state_machine_status(new_state_machine_status : Dictionary):
	print_debug(new_state_machine_status)
	var movement_state_name = new_state_machine_status.get("movement_state")
	var anim_state_name = new_state_machine_status.get("anim_state")
	if movement_state_name != null:
		var new_state = _get_new_state_by_name(movement_state_name)
		movement_state_machine.change_state(new_state)
	if anim_state_name != null:
		var new_state = _get_new_state_by_name(anim_state_name)
		anim_state_machine.change_state(new_state)


func _get_new_state_by_name(state_name: String) -> State:
	if state_name == MS_IdleState.get_name():
		return MS_IdleState.new(self)
	elif state_name == MS_RunState.get_name():
		return MS_RunState.new(self)
	elif state_name == MS_FallState.get_name():
		return MS_FallState.new(self)
	elif state_name == MS_DoubleJumpState.get_name():
		return MS_DoubleJumpState.new(self)
	elif state_name == MS_CrouchState.get_name():
		return MS_CrouchState.new(self)
	elif state_name == MS_UpState.get_name():
		return MS_UpState.new(self)
	elif state_name == MS_HurtState.get_name():
		return MS_HurtState.new(self)
	elif state_name == MS_DieState.get_name():
		return MS_DieState.new(self)
	
	elif state_name == AS_HurtState.get_name():
		return AS_HurtState.new(self)
	elif state_name == AS_AirState.get_name():
		return AS_AirState.new(self)
	elif state_name == AS_GroundState.get_name():
		return AS_GroundState.new(self)
	elif state_name == AS_DieState.get_name():
		return AS_DieState.new(self)
	return null

puppet func _update_basic_status(basic_status: Dictionary) -> void:
	print_debug(basic_status)
	if(basic_status.has('global_position')):
		self.global_position = basic_status.global_position
	if(basic_status.has('velocity')):
		self.velocity = basic_status.velocity
	if(basic_status.has('gravity')):
		self.gravity = basic_status.gravity
	if(basic_status.has('acceleration')):
		self.acceleration = basic_status.acceleration
	if(basic_status.has('deceleration')):
		self.deceleration = basic_status.deceleration
