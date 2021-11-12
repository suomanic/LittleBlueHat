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

onready var label = $Label
onready var label2 = $Label2

# 记录上一次同步的状态机状态
onready var state_machine_status : Dictionary = {
	movement_state = "",
	anim_state = ""
}

func _ready():
	movement_state_machine.change_state(MS_IdleState.new(self))
	anim_state_machine.change_state(AS_GroundState.new(self))
	
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
		
	if movement_module.is_on_object and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)
	
	# 如果处于联机模式下且自己是master节点
	if self.get_tree().has_network_peer() and self.is_network_master():
		var new_state_machine_status:Dictionary = {}
		
		var curr_movement_state_name: String = ""
		var curr_anim_state_name: String = ""
		
		# 如果movement_state_machine和anim_state_machine的状态都不为null，
		# 则将其状态的名称存入curr_movement_state_name和curr_anim_state_name内
		if movement_state_machine.current_state != null:
			curr_movement_state_name = movement_state_machine.current_state.get_name()
		if anim_state_machine.current_state != null:
			curr_anim_state_name = anim_state_machine.current_state.get_name()
		
		# 如果上一次同步的状态机状态（state_machine_status）和当前的状态机状态不一样，
		# 将变更过的内容放入new_state_machine_status内并更新state_machine_status
		if curr_movement_state_name != state_machine_status.movement_state:
			state_machine_status.movement_state = curr_movement_state_name
			new_state_machine_status.movement_state = curr_movement_state_name
		if curr_anim_state_name != state_machine_status.anim_state :
			state_machine_status.anim_state = curr_anim_state_name
			new_state_machine_status.anim_state = curr_anim_state_name
		
		# 如果new_state_machine_status为空，则说明当前状态机的状态和上一次同步时相比没有改变，
		# 则不进行同步。否则，同步。
		if !new_state_machine_status.empty():
			self.rpc_unreliable('_change_state_machine_status', new_state_machine_status)

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
	owner.queue_free()

# 接收rpc调用同步状态机状态
puppet func _change_state_machine_status(new_state_machine_status : Dictionary):
	print_debug(new_state_machine_status)
	
	var movement_state_name = new_state_machine_status.get("movement_state")
	var anim_state_name = new_state_machine_status.get("anim_state")
	
	if movement_state_name != null:
		movement_state_name = str(movement_state_name)
		if movement_state_machine.current_state.get_name() != movement_state_name:
			var new_state = _get_new_state_by_name(movement_state_name)
			movement_state_machine.change_state(new_state)
	if anim_state_name != null:
		anim_state_name = str(anim_state_name)
		if anim_state_machine.current_state.get_name() != anim_state_name:
			var new_state = _get_new_state_by_name(anim_state_name)
			anim_state_machine.change_state(new_state)

# 输入State的name，返回一个新建的State对象，如果找不到对应的State，则返回null
func _get_new_state_by_name(state_name: String) -> State:
	# movement state
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
	# animation state
	elif state_name == AS_HurtState.get_name():
		return AS_HurtState.new(self)
	elif state_name == AS_AirState.get_name():
		return AS_AirState.new(self)
	elif state_name == AS_GroundState.get_name():
		return AS_GroundState.new(self)
	elif state_name == AS_DieState.get_name():
		return AS_DieState.new(self)
	return null
