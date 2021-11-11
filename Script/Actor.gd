extends KinematicBody2D
class_name Actor

export var gravity:float = 600.0
export var acceleration:float = 30.0
export var deceleration:float = 30.0
export var velocity: = Vector2()
puppet func _update_basic_status(basic_status: Dictionary) -> void:
	print_debug(basic_status)
	self.position = basic_status.position
	self.velocity = basic_status.velocity
	self.gravity = basic_status.gravity
	self.acceleration = basic_status.acceleration
	self.deceleration = basic_status.deceleration
