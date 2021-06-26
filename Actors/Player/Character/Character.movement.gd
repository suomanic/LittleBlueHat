extends Node

#走出平台后的跳跃缓冲时间（土狼时间）
var coyote_time: = 0.1
var _coyote_counter: = 0.0

#落地前的跳跃提前输入时间
var jump_buffer_time := 0.1
var _jump_buffer_counter := 0.0

#落下与跳跃取消的重力倍数
var fall_mutiply: = 1.5
var jump_cancel_mutiply: = 1.2

var jump_count: = 0

export var max_speed: = 100.0
export var jump_force := 200
export var double_jump_force := 180

func _physics_process(delta):
	apply_gravity(delta)
	owner.velocity = owner.move_and_slide(owner.velocity,Vector2.UP,false,4,PI/4,false)
	
	
	print_debug(owner.is_on_floor())
	
	if owner.is_on_floor():
		jump_count = 0
		_coyote_counter = coyote_time
	else :
		_coyote_counter -= delta
		
	if owner.owner.input_module.is_jump_pressed:
		_jump_buffer_counter = jump_buffer_time
	else:
		_jump_buffer_counter -= delta
		
func jump():
	# single jump
	if _coyote_counter > 0 and _jump_buffer_counter > 0 and  jump_count == 0:
		 owner.velocity.y = -jump_force;
		 _jump_buffer_counter = 0
		 jump_count += 1
	
	# fall to double jump
	elif  jump_count == 0 and _coyote_counter < 0 and ! owner.is_on_floor() :
		 jump_count = 1
		
	# double jump
	elif jump_count == 1 and jump_count < 2 and  owner.owner.input_module.is_jump_pressed:
		 owner.velocity.y = -double_jump_force;
		 _jump_buffer_counter = 0
		 jump_count += 1
		

func move():
	if owner.owner.input_module.get_direction().x == 0:
		if owner.velocity.x > 0:
			owner.velocity.x = max(owner.velocity.x - owner.deceleration,0)
		elif owner.velocity.x < 0:
			owner.velocity.x = min(owner.velocity.x + owner.deceleration,0)
	elif owner.owner.input_module.is_right_pressed:
		owner.velocity.x = min(owner.velocity.x + owner.acceleration,max_speed)
	elif owner.owner.input_module.is_left_pressed:
		owner.velocity.x = max(owner.velocity.x - owner.acceleration,-max_speed)
	
func crouch_move():
	if owner.owner.input_module.get_direction().x == 0:
		if owner.velocity.x > 0:
			owner.velocity.x = max(owner.velocity.x - owner.deceleration,0)
		elif owner.velocity.x < 0:
			owner.velocity.x = min(owner.velocity.x + owner.deceleration,0)
	elif owner.owner.input_module.is_right_pressed:
		owner.velocity.x = min(owner.velocity.x + owner.acceleration,20)
	elif owner.owner.input_module.is_left_pressed:
		owner.velocity.x = max(owner.velocity.x - owner.acceleration,-20)
	
	
func apply_gravity(delta):
	if owner.velocity.y < 0 and Input.is_action_just_released("jump"):
		owner.velocity.y = owner.velocity.y * 0.5
		owner.velocity.y += owner.gravity * jump_cancel_mutiply * delta
			
	elif owner.velocity.y > 0 and jump_count != 0:
		owner.velocity.y += owner.gravity * fall_mutiply * delta
		
	elif !owner.is_on_floor():
		owner.velocity.y += owner.gravity * delta
	
	elif owner.is_on_floor():
		owner.velocity.y += owner.gravity / 4 * delta
