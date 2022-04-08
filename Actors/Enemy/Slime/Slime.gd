extends Actor

var state_machine : StateMachine
var element_state : String

var can_change_element := true

var can_cause_squish_damage
var player

#元素状态在编辑器中操作
enum DROPOFF { fire,normal,ice }
export(DROPOFF) var element


const N_IdleState = preload("res://Actors/Enemy/Slime/State/N_Idle.gd")
const I_IdleState = preload("res://Actors/Enemy/Slime/State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Enemy/Slime/State/F_Idle.gd")

const N_MoveState = preload("res://Actors/Enemy/Slime/State/N_Move.gd")
const F_WanderState = preload("res://Actors/Enemy/Slime/State/F_Wander.gd")
const F_ChaseState = preload("res://Actors/Enemy/Slime/State/F_Chase.gd")

const NtoIState = preload("res://Actors/Enemy/Slime/State/NtoI.gd")
const ItoNState = preload("res://Actors/Enemy/Slime/State/ItoN.gd")
const NtoFState = preload("res://Actors/Enemy/Slime/State/NtoF.gd")
const FtoNState = preload("res://Actors/Enemy/Slime/State/FtoN.gd")

onready var audio_player = $AudioStreamPlayer2D
onready var anim_player = $AnimationPlayer

onready var f_ray_cast = $FrontRayCast
onready var b_ray_cast = $BackRayCast

#着地检测
onready var r_ground_ray_cast = $RightGroundRaycast
onready var l_ground_ray_cast = $LeftGroundRaycast

onready var sprite_sheet = $AnimationSheet

onready var collision_module = $SlimeCollision
onready var movement_module = $SlimeMovement

onready var physic_collsion = $PhysicCollision
onready var squish_collsion = $SquishHitBox/CollisionShape2D
onready var hit_collision = $HitBox/CollisionShape2D
onready var player_detectshape = $PlayerDetector/PlayerDetectShape

onready var SDM_Timer = $SquishDamageMoveTimer

# 记录上一次同步的状态机状态
var last_sync_statemachine_status : Dictionary = {}
# 记录上一次同步的属性状态
var last_sync_property_status: Dictionary = {}
# 记录上一次同步的node属性状态
var last_sync_node_status: Dictionary = {}
# 定时强行同步的计时器（需要定时同步防止因为丢包造成问题）
var sync_status_timer:Timer

func _ready():
	#将每个对象的物理碰撞独立出来
	get_node("PhysicCollision").shape = get_node("PhysicCollision").shape.duplicate()
	
	state_machine = StateMachine.new(N_MoveState.new(self))
	element_state = "Normal"
	
	#初始化元素状态
	match element:
		DROPOFF.fire:
			physic_collsion.call_deferred("change_to_fire_collision_box")
			state_machine.change_state(F_IdleState.new(self))
			element_state = "Fire"
		DROPOFF.normal:
			physic_collsion.call_deferred("change_to_normal_collision_box")
			state_machine.change_state(N_IdleState.new(self))
			element_state = "Normal"
		DROPOFF.ice:
			physic_collsion.call_deferred("change_to_ice_collision_box")
			state_machine.change_state(I_IdleState.new(self))
			element_state = "Ice"
	
	player_detectshape.disabled = true
	
	sync_timer_init(sync_status_timer)
	
func _physics_process(delta):
	state_machine.update()
	
	switch_can_cause_squish_damage()
	
	if movement_module.is_moving_finished and can_change_element and (element_state == "Fire") and player != null:
		state_machine.change_state(F_ChaseState.new(self))
	
	sync_status()
	
func _turn_around():
	if movement_module.is_moving_finished and movement_module.is_on_object:
		movement_module.is_moving_left = !movement_module.is_moving_left
		scale.x = -scale.x

func _on_HitBox_area_entered(area):
	if can_change_element:
		if area.get_owner().is_in_group("Ice"):
			print_debug("ice damage")
#			if area.get_owner().get_owner().is_in_group("Player"):
#				if global_position.x - area.owner.owner.get_node("Character").global_position.x > 0:
#					movement_module.is_hurt_move_left = true
#				elif global_position.x - area.owner.owner.owner.get_node("Character").global_position.x < 0:
#					movement_module.is_hurt_move_left = false
			match element_state:
				"Normal":
					state_machine.change_state(NtoIState.new(self))
				"Ice":
					anim_player.play("I_Shake_Anim")
				"Fire":
					state_machine.change_state(FtoNState.new(self))
		elif area.owner.is_in_group("Fire"):
			print_debug("fire damage")
			match element_state:
				"Normal":
					state_machine.change_state(NtoFState.new(self))
				"Ice":
					state_machine.change_state(ItoNState.new(self))
				"Fire":
					pass
			
	pass # Replace with function body.

func normal_to_ice_end():
	state_machine.change_state(I_IdleState.new(self))

func normal_to_fire_end():
	state_machine.change_state(F_IdleState.new(self))

func ice_to_normal_end():
	state_machine.change_state(N_IdleState.new(self))
	
func fire_to_normal_end():
	state_machine.change_state(N_IdleState.new(self))
	
	
func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player") :
		player = body
	pass # Replace with function body.

func _on_PlayerDetector_body_exited(body):
	print_debug("player gone")
	if body.is_in_group("Player") :
		player = null
	pass


func switch_can_cause_squish_damage():
	if movement_module.gravity > 0 and element_state == "Ice":
		can_cause_squish_damage = true
	else:
		can_cause_squish_damage = false


func inside_icefog():
	if can_change_element:
		match element_state:
			"Normal":
				state_machine.change_state(NtoIState.new(self))
			"Fire":
				state_machine.change_state(FtoNState.new(self))


func sync_status(reliable:bool = false):
	# 如果处于联机模式下
	if get_tree().has_network_peer() \
	and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		# 如果自己是master节点
		if is_network_master():
			## 同步property_status ##
			var diff_property_status :Dictionary = {}
			# 如果上一次同步的内容（last_sync_property_status）和当前内容不一样，
			# 将变更过的内容放入diff_property_status内, 同时更新last_sync_property_status
			diff_property_status = EntitySyncManager.update_property_dict(
				self.get_path(), [
					'element_state', 'can_change_element', 'can_cause_squish_damage', 
					'velocity', 'gravity', 'deceleration', 'acceleration', 'global_position', 'scale', 
					'movement_module.velocity', 'movement_module.gravity', 'movement_module.deceleration', 
					'movement_module.is_normal_move', 'movement_module.is_fire_move', 'movement_module.is_hurt_move_left', 
					'movement_module.is_moving_left', 'movement_module.is_moving_finished', 'movement_module.is_on_object'
				], last_sync_property_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_property_status.values().empty():
				if(reliable):
					EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_property', self.get_path(), diff_property_status, false)
				else:
					EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_property', self.get_path(), diff_property_status, false)
			
			## 同步statemachine_status ##
			var diff_statemachine_status:Dictionary = {}
			# 如果上一次同步的内容（last_sync_statemachine_status）和当前内容不一样，
			# 将变更过的内容放入diff_statemachine_status内, 同时更新last_sync_statemachine_status
			diff_statemachine_status = EntitySyncManager.update_statemachine_dict(
				self.get_path(),
				['state_machine'], 
				last_sync_statemachine_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_statemachine_status.values().empty():
				if(reliable):
					EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), diff_statemachine_status, false)
				else:
					EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), diff_statemachine_status, false)
			
			## 同步node_status ##
			var diff_node_status :Dictionary = {}
			# 如果上一次同步的内容（last_sync_node_status）和当前内容不一样，
			# 将变更过的内容放入diff_node_status内, 同时更新last_sync_node_status
			diff_node_status = EntitySyncManager.update_node_dict(
				self.get_path(),
				['player'],
				last_sync_node_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_node_status.values().empty():
				EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_node', self.get_path(), diff_node_status, false)


func clear_last_sync_status():
	last_sync_property_status.clear()
	last_sync_statemachine_status.clear()
	last_sync_node_status.clear()


func sync_timer_init(timer: Timer):
	if typeof(timer)== TYPE_OBJECT:
		timer.call('stop')
	timer = Timer.new()
	timer.one_shot = false
	timer.process_mode = 1
	timer.wait_time = 2
	timer.connect("timeout", self, "clear_last_sync_status")
	add_child(timer)
	timer.start()


# 输入State的name，返回一个新建的State对象，如果找不到对应的State，则返回null
func get_new_state_by_name(state_name) -> State:
	var state_array = [
		N_IdleState,I_IdleState,F_IdleState,
		N_MoveState,F_WanderState,F_ChaseState,
		NtoIState,ItoNState,NtoFState,FtoNState
	]
	for state_i in state_array:
		if state_name == state_i.get_name():
			return state_i.new(self)
	return null

