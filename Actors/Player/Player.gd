extends Actor

var hp = 4

# movement state machine
onready var movement_state_machine: StateMachine = get_node("PlayerMovementStateMachine")

# animation state machine
onready var anim_state_machine : StateMachine = get_node("PlayerAnimStateMachine")
onready var input_module = get_node("PlayerInput")
# preload movement states
const MS_IdleState = preload("res://Actors/Player/MovementState/MS_Idle.gd")
const MS_RunState = preload("res://Actors/Player/Movementstate/MS_Run.gd")
const MS_FallState = preload("res://Actors/Player/Movementstate/MS_Fall.gd")
const MS_DoubleJumpState = preload("res://Actors/Player/Movementstate/MS_DoubleJump.gd")
const MS_CrouchState = preload("res://Actors/Player/Movementstate/MS_Crouch.gd")
const MS_UpState = preload("res://Actors/Player/Movementstate/MS_Up.gd")
const MS_HurtState = preload("res://Actors/Player/MovementState/MS_Hurt.gd")
const MS_DieState = preload("res://Actors/Player/MovementState/MS_Die.gd")
const MS_AbsorbedState = preload("res://Actors/Player/MovementState/MS_Absorbed.gd")
const MS_EjectedState = preload("res://Actors/Player/MovementState/MS_Ejected.gd")

# preload aniamtion states
const AS_HurtState = preload("res://Actors/Player/AnimState/Tier1_State/AS_Hurt.gd")
const AS_AirState = preload("res://Actors/Player/AnimState/Tier1_State/AS_Air.gd")
const AS_GroundState = preload("res://Actors/Player/Animstate/Tier1_State/AS_Ground.gd")
const AS_DieState = preload("res://Actors/Player/AnimState/Tier1_State/AS_Die.gd")

# separate code module reference
onready var movement_module = $PlayerMovement
onready var collision_module = $PlayerCollision

# collision references
onready var ground_ray_cast_l = $RayCastL
onready var ground_ray_cast_r = $RayCastR
onready var standing_collision = $Standing_Shape
#onready var crouching_collision = $Crouching_Shape
onready var squish_collision = $SquishHitBox/CollisionShape2D
onready var trigger_collision = $Trigger/TriggerBox
onready var trigger = $Trigger

# animation references
onready var movement_anim_player = $MovementAnimPlayer
onready var effect_anim_player = $EffectAnimPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet

onready var foot_step_audio_player = $FootStepAudioPlayer
onready var jump_land_audio_player = $JumpLandAudioPlayer

# timer
onready var hurt_move_timer = $HurtMoveTimer

onready var anim_sprite = $AnimSpriteSheet

#particles
onready var walk_particles= $WalkParticles
onready var eject_particles = $EjectParticles

onready var debug_label = $DebugInfoLabel
onready var name_label = $NameLabel

export(Curve) var absorbed_curve
export(Curve) var eject_curve

var current_absorb_bubble
var eject_angle
var temp_rand_name

var pre_foot_step_sound = -1


# 记录上一次同步的状态机状态
onready var last_sync_statemachine_status : Dictionary = {
	movement_state_machine = "",
	anim_state_machine = ""
}
# 记录上一次同步的属性状态
onready var last_sync_property_status: Dictionary = {
	"global_position" : global_position,
	"velocity" : velocity,
	"gravity" : gravity,
	"acceleration" : acceleration,
	"deceleration" : deceleration,
	"movement_module.jump_count" : 0,
	"movement_module.is_on_object" : true
}

# 定时强行同步的计时器（需要定时同步防止因为丢包造成问题）
var sync_status_timer:Timer

func _ready():
	movement_state_machine = StateMachine.new(MS_IdleState.new(self))
	anim_state_machine = StateMachine.new(AS_GroundState.new(self))
	
	sync_status_timer = Timer.new()
	sync_status_timer.one_shot = false
	sync_status_timer.process_mode = 1
	sync_status_timer.wait_time = 2
	sync_status_timer.connect("timeout", self, "clear_last_sync_status")
	add_child(sync_status_timer)
	sync_status_timer.start()

func _physics_process(delta) -> void:
	anim_state_machine.update()
	movement_state_machine.update()
	# test only
	if GlobalConfig.debug_mode:
		var temp_debug_text:String = ''
		if anim_state_machine.current_state != null:
			temp_debug_text = 'A: ' + anim_state_machine.current_state.get_name()
		if movement_state_machine.current_state != null:
			temp_debug_text += '\nM: ' + movement_state_machine.current_state.get_name()
		debug_label.text = temp_debug_text
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		var str1 :String
#		str1 = collision.collider.name
#		if str1.begins_with("Slime"):
#			pass
		
	if movement_module.is_on_object and abs(velocity.x) > 40:
		walk_particles.set_emitting(true)
	else :
		walk_particles.set_emitting(false)
	
	sync_status()

func sync_status():
	# 如果处于联机模式下
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		# 如果自己不是master节点
		if !self.is_network_master():
			name_label.text = MultiplayerState.remote_player_info['custom_name']
		# 如果自己是master节点
		else:
			name_label.text = MultiplayerState.my_player_info['custom_name']
			
			## 同步statemachine_status ##
			var diff_statemachine_status:Dictionary = {}
			# 如果上一次同步的内容（last_sync_statemachine_status）和当前内容不一样，
			# 将变更过的内容放入diff_statemachine_status内, 同时更新last_sync_statemachine_status
			diff_statemachine_status = EntitySyncManager.update_statemachine_dict(
				self.get_path(),
				['movement_state_machine','anim_state_machine'], 
				last_sync_statemachine_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_statemachine_status.values().empty():
				EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), diff_statemachine_status, false)
			
			## 同步property_status ##
			var diff_property_status :Dictionary = {}
			# 如果上一次同步的内容（last_sync_property_status）和当前内容不一样，
			# 将变更过的内容放入diff_property_status内, 同时更新last_sync_property_status
			diff_property_status = EntitySyncManager.update_property_dict(
				self.get_path(),
				['global_position','velocity','gravity','acceleration','deceleration','movement_module.jump_count','movement_module.is_on_object'], 
				last_sync_property_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_property_status.values().empty():
				EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_property', self.get_path(), diff_property_status, false)

func clear_last_sync_status():
	last_sync_statemachine_status.clear()
	last_sync_property_status.clear()
	
func absorbed_by_bubble(bubble):
	movement_state_machine.change_state(MS_AbsorbedState.new(self))
	current_absorb_bubble = bubble
	
func ejected_from_bubble(eject_angle :float ,bubble):
	self.eject_angle = eject_angle
	movement_state_machine.change_state(MS_EjectedState.new(self))
	current_absorb_bubble = bubble

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

func anim_call_play_foot_step_sound():
	var i = randi() % 8
	
	while pre_foot_step_sound == i:
		i = randi() % 8
	
	match i :
		0:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep1.wav")
		1:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep2.wav")
		2:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep3.wav")
		3:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep4.wav")
		4:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep5.wav")
		5:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep6.wav")
		6:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep7.wav")
		7:
			foot_step_audio_player.stream = preload("res://Assets/Audio/FootStep/footstep8.wav")
			
	foot_step_audio_player.play()
	pre_foot_step_sound = i


# 输入State的name，返回一个新建的State对象，如果找不到对应的State，则返回null
func get_new_state_by_name(state_name) -> State:
	# movement state
	var state_array = [
		MS_IdleState, MS_RunState, MS_FallState, MS_DoubleJumpState, 
		MS_CrouchState, MS_UpState, MS_HurtState, MS_DieState, AS_HurtState, 
		AS_AirState, AS_GroundState, AS_DieState]
	for state_i in state_array:
		if state_name == state_i.get_name():
			return state_i.new(self)
	return null
