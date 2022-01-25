extends Node2D

var is_right_pressed :bool
var is_left_pressed :bool
var is_jump_pressed :bool
var is_crouch_pressed :bool
var is_attack_just_pressed :bool
var is_weapon1_just_pressed :bool
var is_weapon2_just_pressed :bool
var is_weapon3_just_pressed :bool
var is_weapon4_just_pressed :bool
var mouse_global_position : Vector2

onready var last_sync_input_status :Dictionary = {
	is_right_pressed = false,
	is_left_pressed = false,
	is_jump_pressed = false,
	is_crouch_pressed = false,
	is_attack_just_pressed = false,
	is_weapon1_just_pressed = false,
	is_weapon2_just_pressed = false,
	is_weapon3_just_pressed = false,
	is_weapon4_just_pressed = false,
	mouse_global_position = null
}

func _init():
	is_right_pressed = false
	is_left_pressed = false
	is_jump_pressed = false
	is_crouch_pressed = false
	is_attack_just_pressed = false
	is_weapon1_just_pressed = false
	is_weapon2_just_pressed = false
	is_weapon3_just_pressed = false
	is_weapon4_just_pressed = false
	
func _physics_process(_delta) -> void:
	# 如果处于联机模式下且自己不是master节点
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
		and !is_network_master():
		return
	mouse_global_position = get_global_mouse_position()
	
	if Input.is_action_pressed("move_right"):
		is_right_pressed = true
	else:
		is_right_pressed = false
		
	if Input.is_action_pressed("move_left"):
		is_left_pressed = true
	else:
		is_left_pressed = false
		
	if Input.is_action_just_pressed("jump"):
		is_jump_pressed = true
	else:
		is_jump_pressed = false
		
	if Input.is_action_pressed("Crouch"):
		is_crouch_pressed = true
	else:
		is_crouch_pressed = false
	
	if Input.is_action_just_pressed("attack"):
		is_attack_just_pressed = true
	else:
		is_attack_just_pressed = false
		
	if Input.is_action_just_pressed("weapon1"):
		is_weapon1_just_pressed = true
	else:
		is_weapon1_just_pressed = false
	
	if Input.is_action_just_pressed("weapon2"):
		is_weapon2_just_pressed = true
	else:
		is_weapon2_just_pressed = false
	
	if Input.is_action_just_pressed("weapon3"):
		is_weapon3_just_pressed = true
	else:
		is_weapon3_just_pressed = false
		
	if Input.is_action_just_pressed("weapon4"):
		is_weapon4_just_pressed = true
	else:
		is_weapon4_just_pressed = false
	
	return # debug
	# 如果处于联机模式下且自己是master节点
	if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
		and is_network_master():
		var new_input_status:Dictionary = {}
		if is_right_pressed != last_sync_input_status.is_right_pressed:
			last_sync_input_status.is_right_pressed = is_right_pressed
			new_input_status.is_right_pressed = is_right_pressed
		if is_left_pressed != last_sync_input_status.is_left_pressed:
			last_sync_input_status.is_left_pressed = is_left_pressed
			new_input_status.is_left_pressed = is_left_pressed
		if is_jump_pressed != last_sync_input_status.is_jump_pressed:
			last_sync_input_status.is_jump_pressed = is_jump_pressed
			new_input_status.is_jump_pressed = is_jump_pressed
		if is_crouch_pressed != last_sync_input_status.is_crouch_pressed:
			last_sync_input_status.is_crouch_pressed = is_crouch_pressed
			new_input_status.is_crouch_pressed = is_crouch_pressed
		if is_attack_just_pressed != last_sync_input_status.is_attack_just_pressed:
			last_sync_input_status.is_attack_just_pressed = is_attack_just_pressed
			new_input_status.is_attack_just_pressed = is_attack_just_pressed
		if is_weapon1_just_pressed != last_sync_input_status.is_weapon1_just_pressed:
			last_sync_input_status.is_weapon1_just_pressed = is_weapon1_just_pressed
			new_input_status.is_weapon1_just_pressed = is_weapon1_just_pressed
		if is_weapon2_just_pressed != last_sync_input_status.is_weapon2_just_pressed:
			last_sync_input_status.is_weapon2_just_pressed = is_weapon2_just_pressed
			new_input_status.is_weapon2_just_pressed = is_weapon2_just_pressed
		if is_weapon3_just_pressed != last_sync_input_status.is_weapon3_just_pressed:
			last_sync_input_status.is_weapon3_just_pressed = is_weapon3_just_pressed
			new_input_status.is_weapon3_just_pressed = is_weapon3_just_pressed
		if is_weapon4_just_pressed != last_sync_input_status.is_weapon4_just_pressed:
			last_sync_input_status.is_weapon4_just_pressed = is_weapon4_just_pressed
			new_input_status.is_weapon4_just_pressed = is_weapon4_just_pressed
		if mouse_global_position != last_sync_input_status.mouse_global_position:
			last_sync_input_status.mouse_global_position = mouse_global_position
			new_input_status.mouse_global_position = mouse_global_position
		
		if !new_input_status.empty():
			rpc_unreliable("change_input_status", new_input_status)
			pass

puppet func change_input_status(new_input_status: Dictionary):
	#print_debug(new_input_status)
	if new_input_status.has("is_right_pressed"):
		is_right_pressed = new_input_status.get("is_right_pressed")
	if new_input_status.has("is_left_pressed"):
		is_left_pressed = new_input_status.get("is_left_pressed")
	if new_input_status.has("is_jump_pressed"):
		is_jump_pressed = new_input_status.get("is_jump_pressed")
	if new_input_status.has("is_crouch_pressed"):
		is_crouch_pressed = new_input_status.get("is_crouch_pressed")
	if new_input_status.has("is_attack_just_pressed"):
		is_attack_just_pressed = new_input_status.get("is_attack_just_pressed")
	if new_input_status.has("is_weapon1_just_pressed"):
		is_weapon1_just_pressed = new_input_status.get("is_weapon1_just_pressed")
	if new_input_status.has("is_weapon2_just_pressed"):
		is_weapon2_just_pressed = new_input_status.get("is_weapon2_just_pressed")
	if new_input_status.has("is_weapon3_just_pressed"):
		is_weapon3_just_pressed = new_input_status.get("is_weapon3_just_pressed")
	if new_input_status.has("is_weapon4_just_pressed"):
		is_weapon4_just_pressed = new_input_status.get("is_weapon4_just_pressed")
	if new_input_status.has("mouse_global_position"):
		mouse_global_position = new_input_status.get("mouse_global_position")
	pass
	
func get_direction() -> Vector2:
	# 如果处于联机模式下且自己不是master节点
	#if get_tree().has_network_peer() \
	#	and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED \
	#	and !is_network_master():
	#	return Vector2(0, 0)
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump") else 1.0
	)
	
