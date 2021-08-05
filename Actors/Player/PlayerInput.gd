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
	
func _physics_process(delta) -> void:
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
		
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump") else 1.0
		)
	
