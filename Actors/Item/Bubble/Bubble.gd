tool
extends Area2D

# signal absorb_signal

var behavior_state_machine : StateMachine
var element_state_machine : StateMachine
var movement_state_machine : StateMachine

var element_state : String
var can_change_element := true
var move_target

var eject_angle
var absorb_direction := false  #true为右，false为左
var eject_direction := false  #true为右，false为左

onready var audio_player = $AudioStreamPlayer2D

onready var bubble_anim_player = $BubbleAnimationPlayer
onready var arrow_anim_player = $ArrowAniamtionPlayer
onready var character_shadow_anim_player = $CharacterShadowAnimationPlayer
onready var effect_anim_player = $EffectAnimationPlayer

onready var bubble_sprite = $BubbleSprite
onready var arrow_sprite = $BubbleSprite/ArrowSprite
onready var character_shadow_sprite = $BubbleSprite/CharacterShadowSprite
onready var effect_sprite = $BubbleSprite/EffectSprite

onready var enter_shape = $EnterShape
onready var player = null

onready var label = $Label
onready var label2 = $Label2
onready var label3 = $Label3
onready var label4 = $Label4

#movement state
const moveState = preload("res://Actors/Item/Bubble/State/Movement_State/Move.gd")
const idleState = preload("res://Actors/Item/Bubble/State/Movement_State/Idle.gd")

#behavior state
const freeState = preload("res://Actors/Item/Bubble/State/Behavior_State/Free.gd")
const occupiedState = preload("res://Actors/Item/Bubble/State/Behavior_State/Occupied.gd")
const ejectState = preload("res://Actors/Item/Bubble/State/Behavior_State/Eject.gd")

#element state
const I_IdleState = preload("res://Actors/Item/Bubble/State/Element_State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Item/Bubble/State/Element_State/F_Idle.gd")
const N_IdleState = preload("res://Actors/Item/Bubble/State/Element_State/N_Idle.gd")
const ItoNState = preload("res://Actors/Item/Bubble/State/Element_State/ItoN.gd")
const NtoIState = preload("res://Actors/Item/Bubble/State/Element_State/NtoI.gd")
const FtoNState = preload("res://Actors/Item/Bubble/State/Element_State/FtoN.gd")
const NtoFState = preload("res://Actors/Item/Bubble/State/Element_State/NtoF.gd")

export var absorb_curve : Curve
export var eject_curve : Curve
export var move_curve : Curve

export var move_speed := 50

#不同状态下泡泡的目标绝对位置
onready var normal_absolute_position 
onready var ice_absolute_position 
onready var fire_absolute_position 

export var normal_pos : Vector2
export var fire_pos : Vector2
export var ice_pos : Vector2

# 记录上一次同步的状态机状态
var last_sync_statemachine_status : Dictionary = {}
# 记录上一次同步的属性状态
var last_sync_property_status: Dictionary = {}
# 记录上一次同步的node属性状态
var last_sync_node_status: Dictionary = {}
# 记录上一次同步的arrow的属性状态
var last_sync_arrow_property_status: Dictionary = {}
# 定时强行同步的计时器（需要定时同步防止因为丢包造成问题）
var sync_status_timer:Timer


func _ready():
	if not Engine.editor_hint:
		behavior_state_machine = StateMachine.new(freeState.new(self))
		element_state_machine = StateMachine.new(N_IdleState.new(self))
		movement_state_machine = StateMachine.new(idleState.new(self))

		normal_absolute_position = global_position + normal_pos
		ice_absolute_position = global_position + ice_pos
		fire_absolute_position = global_position + fire_pos
	
	sync_timer_init(sync_status_timer)


func _physics_process(delta):
	if  Engine.editor_hint: #只在编辑器中运行的代码，用于在编辑器中显示不同元素下泡泡的目标位置
		get_node("NormalPosition").position = normal_pos
		get_node("IcePosition").position = ice_pos
		get_node("FirePosition").position = fire_pos
	
	if not Engine.editor_hint: #只在游戏中运行的代码
		behavior_state_machine.update()
		element_state_machine.update()
		movement_state_machine.update()
		if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			if is_instance_valid(player) and player.is_network_master():
				eject_angle = (get_global_mouse_position() - bubble_sprite.global_position).angle()
		else:
			eject_angle = (get_global_mouse_position() - bubble_sprite.global_position).angle()
		
		if behavior_state_machine.current_state != null:
			label.text = behavior_state_machine.current_state.get_name()
		if element_state_machine.current_state != null:
			label2.text = element_state_machine.current_state.get_name()	
		label4.text = String(global_position.y)
			
		if absorb_direction :
			character_shadow_sprite.scale.x = 1
		else : 
			character_shadow_sprite.scale.x = -1
	
	sync_status()


func arrow_sprite_movement():
	if not Engine.editor_hint: 
		# 如果处于联机模式下
		if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
		and !(is_instance_valid(player) and player.is_network_master()): # 如果没有玩家进入或者玩家不是master节点
			return
		arrow_sprite.global_position = (get_global_mouse_position() - bubble_sprite.global_position).normalized() * 25 + bubble_sprite.global_position
		arrow_sprite.rotation = (get_global_mouse_position() - bubble_sprite.global_position).angle() + PI/2


func _on_Bubble_body_entered(body):
	if not Engine.editor_hint:
		if body.is_in_group("Player") and player == null:
			var temp_flag:bool = false
			if get_tree().has_network_peer() \
			and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
				if is_network_master():
					temp_flag = true
			else:
				temp_flag = true
			
			if temp_flag:
				if body.collision_module.facing():
					absorb_direction = true
				else :
					absorb_direction = false
				
				player = body
				# !!!一定要保证player在远程被设置后才变化状态
				EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_node', self.get_path(), {'player':player.get_path()}, false)
				behavior_state_machine.change_state(occupiedState.new(self))


func anim_called_character_shadow_to_idle():
	if not Engine.editor_hint: 
		character_shadow_anim_player.play("idle_anim")
		character_shadow_anim_player.advance(bubble_anim_player.current_animation_position)


func _on_Hitbox_area_entered(area):
	if not Engine.editor_hint: 
		if can_change_element:
			if area.get_owner().is_in_group("Ice"): 
				match element_state:
					"Normal":
						element_state_machine.change_state(NtoIState.new(self))
						movement_state_machine.change_state(moveState.new(self))
					"Ice":
						pass
					"Fire":
						element_state_machine.change_state(FtoNState.new(self))
						movement_state_machine.change_state(moveState.new(self))
			elif area.owner.is_in_group("Fire"): 
				match element_state:
					"Normal":
						element_state_machine.change_state(NtoFState.new(self))
						movement_state_machine.change_state(moveState.new(self))
					"Ice":
						element_state_machine.change_state(ItoNState.new(self))
						movement_state_machine.change_state(moveState.new(self))
					"Fire":
						pass


func eject():
	if get_tree().has_network_peer() \
	and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		# 如果自己的player是master节点
		if is_instance_valid(player) and player.is_network_master():
			if is_network_master():
				behavior_state_machine.change_state(ejectState.new(self))
			else:
				EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), {'behavior_state_machine':ejectState.get_name()}, false)
	else:
		behavior_state_machine.change_state(ejectState.new(self))


func inside_icefog():
	if can_change_element:
		match element_state:
			"Normal":
				element_state_machine.change_state(NtoIState.new(self))
				movement_state_machine.change_state(moveState.new(self))
			"Fire":
				element_state_machine.change_state(FtoNState.new(self))
				movement_state_machine.change_state(moveState.new(self))


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
				self.get_path(),
				['element_state', 'can_change_element', 'move_target', 
				'absorb_direction',
				'normal_absolute_position', 'ice_absolute_position', 'fire_absolute_position',
				'global_position'], 
				last_sync_property_status, false)
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
				['behavior_state_machine', 'element_state_machine', 'movement_state_machine'], 
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
		
		# 如果自己的player是master节点
		if is_instance_valid(player) and player.is_network_master():
			## 同步arrow_property_status ##
			var diff_arrow_property_status :Dictionary = {}
			# 如果上一次同步的内容（last_sync_arrow_property_status）和当前内容不一样，
			# 将变更过的内容放入diff_arrow_property_status内, 同时更新last_sync_arrow_property_status
			diff_arrow_property_status = EntitySyncManager.update_property_dict(
				self.get_path(),
				['eject_angle', 'eject_direction',
				'arrow_sprite.rotation', 'arrow_sprite.global_position'], 
				last_sync_arrow_property_status, false)
			# 如果和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_arrow_property_status.values().empty():
				if(reliable):
					EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_property', self.get_path(), diff_arrow_property_status, false)
				else:
					EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_property', self.get_path(), diff_arrow_property_status, false)
			pass

func clear_last_sync_status():
	last_sync_property_status.clear()
	last_sync_statemachine_status.clear()
	last_sync_node_status.clear()
	last_sync_arrow_property_status.clear()


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
		moveState, idleState,
		freeState, occupiedState, ejectState,
		I_IdleState, F_IdleState, N_IdleState, ItoNState, NtoIState, FtoNState, NtoFState]
	for state_i in state_array:
		if state_name == state_i.get_name():
			return state_i.new(self)
	return null

