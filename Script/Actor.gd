extends KinematicBody2D
class_name Actor

export var gravity:float = 600.0
export var acceleration:float = 30.0
export var deceleration:float = 30.0
export var velocity: = Vector2()

# 接收rpc调用同步基础状态
puppet func _update_basic_status(basic_status: Dictionary) -> void:
	#print_debug(basic_status)
	if(basic_status.has('global_position')):
		self.global_position = basic_status.global_position
	if(basic_status.has('velocity')):
		self.velocity = basic_status.velocity
	if(basic_status.has('gravity')):
		self.gravity = basic_status.gravity
	if(basic_status.has('acceleration')):
		self.acceleration = basic_status.acceleration
	if(basic_status.has('deceleration')):
		self.deceleration = basic_status.deceleration
