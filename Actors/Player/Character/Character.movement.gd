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

var is_on_object:bool

export var max_speed: = 100.0
export var jump_force := 200
export var double_jump_force := 180


func _physics_process(delta):
	owner.velocity = owner.move_and_slide(owner.velocity,Vector2.UP,false,4,PI/4,false)
	if is_on_object:
		jump_count = 0
		_coyote_counter = coyote_time
	else :
		_coyote_counter -= delta
		
	if owner.owner.input_module.is_jump_pressed:
		_jump_buffer_counter = jump_buffer_time
	else:
		_jump_buffer_counter -= delta
	
	# 如果处于联机模式下且自己是master节点
	if owner.get_tree().has_network_peer() and owner.is_network_master():
		var basic_status: Dictionary = {
			position = owner.position,
			velocity = owner.velocity,
			gravity = owner.gravity,
			acceleration = owner.acceleration,
			deceleration = owner.deceleration
		}
		owner.rpc_unreliable('_update_basic_status', basic_status)

func jump():
	# single jump
	if _coyote_counter > 0 and _jump_buffer_counter > 0 and jump_count == 0:
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
	
	# 如果处于联机模式下且自己是master节点
	if owner.get_tree().has_network_peer() and owner.is_network_master():
		var basic_status: Dictionary = {
			position = owner.position,
			velocity = owner.velocity,
			gravity = owner.gravity,
			acceleration = owner.acceleration,
			deceleration = owner.deceleration
		}
		owner.rpc_unreliable('_update_basic_status', basic_status)
	else:
		print_debug('do not rpc!!!')
		
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
	
	# 如果处于联机模式下且自己是master节点
	if owner.get_tree().has_network_peer() and owner.is_network_master():
		var basic_status: Dictionary = {
			position = owner.position,
			velocity = owner.velocity,
			gravity = owner.gravity,
			acceleration = owner.acceleration,
			deceleration = owner.deceleration
		}
		owner.rpc_unreliable('_update_basic_status', basic_status)
	else:
		print_debug('do not rpc!!!')
	
#简单复制，需要修改
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
	
	# 如果处于联机模式下且自己是master节点
	if owner.get_tree().has_network_peer() and owner.is_network_master():
		var basic_status: Dictionary = {
			position = owner.position,
			velocity = owner.velocity,
			gravity = owner.gravity,
			acceleration = owner.acceleration,
			deceleration = owner.deceleration
		}
		owner.rpc_unreliable('_update_basic_status', basic_status)
	else:
		print_debug('do not rpc!!!')
	
func apply_gravity(delta):
	# max velocity.y
	if owner.hp <= 0: 
		owner.velocity.y = min(owner.velocity.y,100)
	else:
		owner.velocity.y = min(owner.velocity.y,800)
	
	if owner.ground_ray_cast_l.is_colliding() or owner.ground_ray_cast_r.is_colliding():
			owner.gravity -= 100
			owner.gravity = max(0,owner.gravity)
			is_on_object = true
	else :
		owner.gravity = 600
		is_on_object = false
	
	if owner.velocity.y < 0 and Input.is_action_just_released("jump"):
		owner.velocity.y = owner.velocity.y * 0.5
		owner.velocity.y += owner.gravity * jump_cancel_mutiply * delta
			
	elif owner.velocity.y > 0 and jump_count != 0:
		owner.velocity.y += owner.gravity * fall_mutiply * delta
		
	elif !is_on_object:
		owner.velocity.y += owner.gravity * delta
	
	elif is_on_object:
		owner.velocity.y += owner.gravity / 4 * delta
		
	# 如果处于联机模式下且自己是master节点
	if owner.get_tree().has_network_peer() and owner.is_network_master():
		var basic_status: Dictionary = {
			position = owner.position,
			velocity = owner.velocity,
			gravity = owner.gravity,
			acceleration = owner.acceleration,
			deceleration = owner.deceleration
		}
		owner.rpc_unreliable('_update_basic_status', basic_status)
	else:
		print_debug('do not rpc!!!')

func bounce():
	jump_count = 1
	owner.velocity.y = -300
	
	# 如果处于联机模式下且自己是master节点
	if owner.get_tree().has_network_peer() and owner.is_network_master():
		var basic_status: Dictionary = {
			position = owner.position,
			velocity = owner.velocity,
			gravity = owner.gravity,
			acceleration = owner.acceleration,
			deceleration = owner.deceleration
		}
		owner.rpc_unreliable('_update_basic_status', basic_status)
	else:
		print_debug('do not rpc!!!')

# 精灵图scale.x转换暂时写在这里
func hurt_move(will_go_left):
	
	if will_go_left:
		owner.velocity = Vector2(125 , -150) 
		if !owner.collision_module.is_facing_left:
			owner.anim_sprite.scale.x = -owner.anim_sprite.scale.x
			owner.collision_module.is_facing_left = !owner.collision_module.is_facing_left
	else :
		owner.velocity = Vector2(-125 , -150)  
			
		if owner.collision_module.is_facing_left:
			owner.anim_sprite.scale.x = -owner.anim_sprite.scale.x
			owner.collision_module.is_facing_left = !owner.collision_module.is_facing_left
	pass
	
