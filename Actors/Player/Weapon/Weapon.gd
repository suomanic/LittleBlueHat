extends Node2D

class_name Weapon
# Called when the node enters the scene tree for the first time.

onready var state_machine : StateMachine

onready var weapon_data :={
	F_sword = preload("res://Actors/Player/Weapon/Sword/FireSword.tscn"),
	I_sword = preload("res://Actors/Player/Weapon/Sword/IceSword.tscn"),
	F_orb = preload("res://Actors/Player/Weapon/MagicOrb/FireMagicOrb.tscn"),
	I_orb = preload("res://Actors/Player/Weapon/MagicOrb/IceMagicOrb.tscn")
}

const readyState = preload("res://Actors/Player/Weapon/State/ready.gd")
const absorbedState = preload("res://Actors/Player/Weapon/State/absorbed.gd")

export(Curve) var absorbed_position_curve
export(Curve) var absorbed_scale_curve

var absolute_position

var can_attack
var can_change_weapon

var change_weapon_cd = 0.5
var change_weapon_counter

var current_weapon
	
# 追随角色的该武器(self)是否正在换边过程中
var on_changing_side : = Vector2(false, false)
# 跟随玩家时线性插值的取值间隔
var follow_player_linear_interpolate_scale_rate : = Vector2(0.2, 0.35)

onready var target_weapon_to_change_name = "I_sword"
onready var current_weapon_name
onready var target_position_to_change = global_position

# 记录上一次同步的状态机状态
var last_sync_statemachine_status : Dictionary = {}
# 记录上一次同步的属性状态
var last_sync_property_status: Dictionary = {}
var sync_status_timer: Timer

func _ready():
	owner = get_parent()
	state_machine = StateMachine.new(readyState.new(self))
	change_weapon_counter = change_weapon_cd
	
	sync_timer_init(sync_status_timer)


func _physics_process(delta):
	state_machine.update()
	change_weapon_counter -= delta
	
	if can_change_weapon and change_weapon_counter < 0:
		if owner.input_module.is_weapon1_just_pressed:
			target_weapon_to_change_name = "F_sword"
		elif owner.input_module.is_weapon2_just_pressed:
			target_weapon_to_change_name = "I_sword"
		elif owner.input_module.is_weapon3_just_pressed:
			target_weapon_to_change_name = "F_orb"
		elif owner.input_module.is_weapon4_just_pressed:
			target_weapon_to_change_name = "I_orb"
	
	if current_weapon_name != target_weapon_to_change_name:
		change_weapon(target_weapon_to_change_name)
	
	sync_status()
	call_attack()


func follow_player():
	# 如果不处于联机模式下，或者自己是master节点
	if (!get_tree().has_network_peer() \
		or get_tree().network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED) \
		or self.is_network_master():
		# 该武器(self)位置和角色位置的固定偏移量，其中fix_offset.x为绝对值
		var fix_offset :=Vector2(13, -10)
		# 该武器(self)位置和角色位置的目标偏移量
		var target_offset : = Vector2(0, 0)
		# 当前鼠标位置和角色位置的偏移量
		var mouse_offset_from_chara : = Vector2(owner.input_module.mouse_global_position -  owner.global_position)
		# 当前该武器(self)位置和角色位置的偏移量
		var weapon_offset_from_chara : = Vector2(global_position - owner.global_position)
		
		# 武器y坐标绝对值的最大值（不包括固定偏移量）
		var max_abs_y : = 16
		# 操控武器y坐标（不包括固定偏移量）的鼠标y坐标绝对值 和 武器y坐标（不包括固定偏移量）的比值
		# 用人话来说，就是鼠标操控范围和武器移动范围的比值，或者称之为放大倍数
		var control_y_ratio : = 2
		
		# 设定target_offset.y
		# 先判断鼠标在角色的上方还是下方，分别处理
		if(mouse_offset_from_chara.y > 0) :
			# 如果鼠标移动到超过鼠标移动范围的区域，则直接设置武器y坐标的绝对值为其最大值（然后还得加上固定偏移量）
			if mouse_offset_from_chara.y > max_abs_y * control_y_ratio :
				target_offset.y = fix_offset.y + max_abs_y
			# 如果鼠标的y坐标偏移量没超过范围，则设置武器y坐标的绝对值为 鼠标的y坐标偏移量/放大倍数（然后还得加上固定偏移量）
			else :
				target_offset.y = fix_offset.y + mouse_offset_from_chara.y / 2
		else :
			# 同上
			if mouse_offset_from_chara.y < - max_abs_y * control_y_ratio :
				target_offset.y = fix_offset.y - max_abs_y
			# 同上
			else :
				target_offset.y = fix_offset.y + mouse_offset_from_chara.y / 2
		
		# 弧线的参数，为椭圆，满足y=asinθ，x=bcosθ（y需要先减去固定偏移量）
		# 注意，ellipse_a不能小于max_abs_y
		var ellipse_a = max_abs_y
		var ellipse_b = ellipse_a / 4
		# θ=arcsin(y/a)（y需要先减去固定偏移量）
		var ellipse_theta = asin((target_offset.y - fix_offset.y) / ellipse_a)
		
		# 设定target_offset.x
		# 先判断鼠标在角色的左边还是右边，分别处理
		if(mouse_offset_from_chara.x > 0) :
			scale.x = 1
			fix_offset.x = +fix_offset.x # 向右偏移
			# x=bcosθ（x需要再加上固定偏移量）
			target_offset.x = fix_offset.x + ellipse_b * cos(ellipse_theta)
			
			# 如果鼠标、该武器(self)并不在角色所在位置的左右两边，但是该武器(self)并没有到达它应该到的位置，
			# 则认为该武器(self)仍在左右换边过程中，不去动on_changing_side.x
			# 否则，则认为该武器(self)的左右换边过程已经结束，设置on_changing_side_x为false
			if weapon_offset_from_chara.x > (target_offset.x - 0.11) :
				on_changing_side.x = false
			# 如果鼠标、该武器(self)正好在角色所在位置的左右两边，说明要换方向了，设置on_changing_side.x为true
			elif weapon_offset_from_chara.x < 0 :
				on_changing_side.x = true
		else :
			scale.x = -1
			fix_offset.x = -fix_offset.x # 向左偏移
			# x=bcosθ（x需要再加上固定偏移量）
			target_offset.x = fix_offset.x - ellipse_b * cos(ellipse_theta)
			
			# 同上
			if weapon_offset_from_chara.x < (target_offset.x + 0.11) :
				on_changing_side.x = false
			# 同上
			elif weapon_offset_from_chara.x > 0 :
				on_changing_side.x = true
		
		# 如果追随角色的该武器(self)正在左右换边，设置一下非线性动画平滑
		if on_changing_side.x :
			follow_player_linear_interpolate_scale_rate.x = 0.25
			
			# 追随角色的该武器(self)正在左右换边时，如果鼠标和角色运动方向同向，
			# 为了防止追不上角色，把follow_player_linear_interpolate_scale_rate.x调大
			if (owner.input_module.get_direction().x > 0 && mouse_offset_from_chara.x > 0) || (owner.input_module.get_direction().x < 0 && mouse_offset_from_chara.x < 0) :
				follow_player_linear_interpolate_scale_rate.x = 0.5
			
		# 如果追随角色的该武器(self)没有在左右换边的过程中，为了防止追不上角色，
		# 把follow_player_linear_interpolate_scale_rate.x调大
		else :
			follow_player_linear_interpolate_scale_rate.x = 0.5
		
		target_position_to_change = Vector2(owner.global_position.x + target_offset.x, owner.global_position.y + target_offset.y)
	# 水平方向非线性动画
	global_position = global_position.linear_interpolate(Vector2(target_position_to_change.x, global_position.y), follow_player_linear_interpolate_scale_rate.x)
	# 垂直方向非线性动画
	global_position = global_position.linear_interpolate(Vector2(global_position.x, target_position_to_change.y), follow_player_linear_interpolate_scale_rate.y)


func change_weapon(weapon_type:String):
	for i in self.get_children():
		i.queue_free()
	
	change_weapon_counter = change_weapon_cd
	
	match weapon_type:
		"F_sword":
			current_weapon = weapon_data.F_sword.instance()
			add_child(current_weapon)
		"I_sword":
			current_weapon = weapon_data.I_sword.instance()
			add_child(current_weapon)
		"F_orb":
			current_weapon = weapon_data.F_orb.instance()
			add_child(current_weapon)
		"I_orb":
			current_weapon = weapon_data.I_orb.instance()
			add_child(current_weapon)
	
	current_weapon_name = target_weapon_to_change_name


func call_attack():
	if owner.input_module.is_attack_just_pressed and can_attack:
		if is_instance_valid(current_weapon) and current_weapon_name != null:
			if str(current_weapon_name).ends_with('sword'):
				# 如果处于联机模式下，且自己是master节点
				if get_tree().has_network_peer() \
				and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
				and owner.is_network_master():
					EntitySyncManager.rpc('call_func', self.get_path(), {'current_weapon.attack':[]})
				current_weapon.call('attack')
			elif str(current_weapon_name).ends_with('orb') and current_weapon.get('shoot_cd_counter') < 0:
				# 如果处于联机模式下，且自己是master节点
				if get_tree().has_network_peer() \
				and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
				and owner.is_network_master():
					EntitySyncManager.rpc('call_func', self.get_path(), {'current_weapon.attack':[]})
				current_weapon.call('attack')
		pass


#从角色接收信号函数处调用
func character_absorbed():
	state_machine.change_state(absorbedState.new(self))
	absolute_position = get_child(0).global_position
	pass


#从角色接收信号函数处调用
func character_exit_absorbed():
	state_machine.change_state(readyState.new(self))
	get_child(0).scale = Vector2(1,1)
	get_child(0).sprite.set_visible(true)


# 输入State的name，返回一个新建的State对象，如果找不到对应的State，则返回null
func get_new_state_by_name(state_name) -> State:
	# movement state
	var state_array = [readyState, absorbedState]
	for state_i in state_array:
		if state_name == state_i.get_name():
			return state_i.new(self)
	return null


func sync_status():
	# 如果处于联机模式下
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		# 如果自己是master节点
		if self.is_network_master():
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
				EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_statemachine', self.get_path(), diff_statemachine_status, false)
			
			## 同步property_status ##
			var diff_property_status :Dictionary = {}
			# 如果上一次同步的内容（last_sync_property_status）和当前内容不一样，
			# 将变更过的内容放入diff_property_status内, 同时更新last_sync_property_status
			diff_property_status = EntitySyncManager.update_property_dict(
				self.get_path(),
				['target_position_to_change', 'target_weapon_to_change_name',
				'follow_player_linear_interpolate_scale_rate','absorbed_position',
				'scale'],
				last_sync_property_status, false)
			# 如果当前状态和上一次同步时相比没有改变，则不进行同步,否则同步
			if !diff_property_status.values().empty():
				EntitySyncManager.rpc_unreliable_id(MultiplayerState.remote_id, 'update_property', self.get_path(), diff_property_status, false)


func clear_last_sync_status():
	last_sync_statemachine_status.clear()
	last_sync_property_status.clear()


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
