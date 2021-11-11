extends KinematicBody2D
class_name Actor

export var gravity:float = 600.0
export var acceleration:float = 30.0
export var deceleration:float = 30.0
export var velocity: = Vector2()
var debug_print_limiter = 100
puppet func _update_basic_status(basic_status: Dictionary) -> void:
	if(debug_print_limiter==0):
		print_debug(basic_status)
		debug_print_limiter=100
	else:
		debug_print_limiter-=debug_print_limiter
	
	self.position = basic_status.position
	self.velocity = basic_status.velocity
	self.gravity = basic_status.gravity
	self.acceleration = basic_status.acceleration
	self.deceleration = basic_status.deceleration
