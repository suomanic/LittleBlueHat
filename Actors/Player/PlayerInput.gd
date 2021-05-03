extends Node

var is_right_pressed = null
var is_left_pressed = null
var is_jump_pressed = null
var is_crouch_pressed = null

func _init():
	is_right_pressed = false
	is_left_pressed = false
	is_jump_pressed = false
	is_crouch_pressed = false
	
func _physics_process(delta) -> void:
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
		
			
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump") else 1.0
		)
	
