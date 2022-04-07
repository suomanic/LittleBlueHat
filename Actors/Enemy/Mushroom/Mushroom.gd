extends Area2D

signal icefog_signal

var state_machine : StateMachine
var element_state
var can_change_element := true

var is_hit_left

export(Curve) var icefog_spread_curve

onready var audio_player = $AudioStreamPlayer2D
onready var anim_player = $AnimationPlayer

onready var collision_module = $MushroomCollision

onready var icefog_particle = $Icefog/Icice
onready var icefog_sprite = $Icefog/Icefog_sprite
onready var icefog_shape = $Icefog/Icefog_area/Icefog_triggershape

# 记录上一次同步的状态机状态
var last_sync_statemachine_status : Dictionary = {}
# 记录上一次同步的属性状态
var last_sync_property_status: Dictionary = {}
# 定时强行同步的计时器（需要定时同步防止因为丢包造成问题）
var sync_status_timer:Timer

const N_IdleState = preload("res://Actors/Enemy/Mushroom/State/N_Idle.gd")
const I_IdleState = preload("res://Actors/Enemy/Mushroom/State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Enemy/Mushroom/State/F_Idle.gd")
const NtoFState = preload("res://Actors/Enemy/Mushroom/State/NtoF.gd")
const NtoIState = preload("res://Actors/Enemy/Mushroom/State/NtoI.gd")
const ItoNState = preload("res://Actors/Enemy/Mushroom/State/ItoN.gd")
const FtoNState = preload("res://Actors/Enemy/Mushroom/State/FtoN.gd")

func _ready():
	state_machine = StateMachine.new(N_IdleState.new(self))
	element_state = "Normal"
	sync_timer_init(sync_status_timer)

func _physics_process(delta):
	state_machine.update()
	sync_status()
	pass

func _on_Hitbox_area_entered(area):
	if area.global_position.x > global_position.x:
		is_hit_left = false
	else :
		is_hit_left = true
	
	if can_change_element:
		if area.owner.is_in_group("Ice"):
			match element_state:
				"Normal":
					state_machine.change_state(NtoIState.new(self))
				"Ice":
					pass
				"Fire":
					state_machine.change_state(FtoNState.new(self))
		elif area.owner.is_in_group("Fire") or (area.owner.is_in_group("Slime") and area.owner.element_state == "Fire"):
			match element_state:
				"Normal":
					state_machine.change_state(NtoFState.new(self))
				"Ice":
					state_machine.change_state(ItoNState.new(self))
				"Fire":
					pass
			

func inside_icefog():
	if can_change_element:
		match element_state:
			"Normal":
				state_machine.change_state(NtoIState.new(self))
			"Fire":
				state_machine.change_state(FtoNState.new(self))
	

func NtoF_anim_end():
	state_machine.change_state(F_IdleState.new(self))

func NtoI_anim_end():
	state_machine.change_state(I_IdleState.new(self))
	
func FtoN_anim_end():
	state_machine.change_state(N_IdleState.new(self))
	
func ItoN_anim_end():
	state_machine.change_state(N_IdleState.new(self))

func _on_Icefog_area_body_entered(body):
	print_debug(body)
	if body.is_in_group("CanChangeElement"):
		connect("icefog_signal",body,"inside_icefog")
	pass # Replace with function body.


func _on_Icefog_area_body_exited(body):
	if body.is_in_group("CanChangeElement"):
		disconnect("icefog_signal",body,"inside_icefog")
	pass # Replace with function body.


func _on_Icefog_area_area_entered(area):
	if area.is_in_group("CanChangeElement"):
		connect("icefog_signal",area,"inside_icefog")
	pass # Replace with function body.


func _on_Icefog_area_area_exited(area):
	if area.is_in_group("CanChangeElement"):
		disconnect("icefog_signal",area,"inside_icefog")
	pass # Replace with function body.


func emit_icefog_signal():
	emit_signal("icefog_signal")

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
				['element_state', 'can_change_element', 'is_hit_left'], 
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
				['state_machine'], 
				last_sync_statemachine_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_statemachine_status.values().empty():
				if(reliable):
					EntitySyncManager.rpc_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), diff_statemachine_status, false)
				else:
					EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), diff_statemachine_status, false)


func clear_last_sync_status():
	last_sync_property_status.clear()
	last_sync_statemachine_status.clear()


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
	var state_array = [N_IdleState,I_IdleState,F_IdleState,
	NtoFState,NtoIState,ItoNState,FtoNState]
	for state_i in state_array:
		if state_name == state_i.get_name():
			return state_i.new(self)
	return null
