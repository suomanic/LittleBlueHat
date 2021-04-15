extends Actor

var direction: = Vector2()
var velocity: = Vector2()

export var acceration: = 15.0
export var max_speed: = 210.0
export var jump_force := 225
export var double_jump_foce := 225

var coyote_time: = 0.1
var _coyote_counter: = 0.0

var jump_buffer_time := 0.1
var _jump_buffer_counter := 0.0

var fall_mutiply: = 1.5
var jump_cancel_mutiply: = 1.2

var jump_count: = 0
var on_ground : = false

func _physics_process(delta: float) -> void:
	direction = get_direction()
	animation_control()
	move()
	jump()
	velocity = move_and_slide(velocity,Vector2.UP)
	
	if is_on_floor():
		on_ground = true
		jump_count = 0
	else :
		on_ground = false
		
	if is_on_floor() and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)
	
	
	
func animation_control():
	if direction.x > 0 :
		$AnimatedSprite.scale.x = 1
		$JumpAnimSheet.scale.x = 1
		$Particles2D.scale.x = 1
		$Particles2D.set_position(Vector2(-4,12))
	elif direction.x < 0 :
		$AnimatedSprite.scale.x = -1
		$JumpAnimSheet.scale.x = -1
		$Particles2D.scale.x = -1
		$Particles2D.set_position(Vector2(4,12))
		
	if on_ground and velocity.x !=0:
		$JumpAnimSheet.set_visible(false)
		$AnimatedSprite.set_visible(true)
		$AnimatedSprite.play("run")
		
	elif on_ground and velocity.x == 0:
		$JumpAnimSheet.set_visible(false)
		$AnimatedSprite.set_visible(true)
		$AnimatedSprite.play("idle")
		
	elif !on_ground:
		var jump_anim_count = jump_force * 0.8 * 2/7
		if jump_count != 2:
			jump_count =1;
		
		if velocity.y <= -jump_force +jump_anim_count:
			if jump_count == 1:
				$JumpAnimSheet.set_frame(0)
				
				$JumpAnimSheet.set_visible(true)
				$AnimatedSprite.set_visible(false)
				
			else :
				$JumpAnimSheet.set_visible(false)
				$AnimatedSprite.set_visible(true)
				$AnimatedSprite.play("doublejump")
				
		elif velocity.y <= -jump_force +jump_anim_count*2 and velocity.y >= -jump_force +jump_anim_count:
			$JumpAnimSheet.set_frame(0)
		elif velocity.y <= -jump_force +jump_anim_count*3 and velocity.y >= -jump_force +jump_anim_count*2:
			$JumpAnimSheet.set_frame(1)
		elif velocity.y <= -jump_force +jump_anim_count*4 and velocity.y >= -jump_force +jump_anim_count*3:
			$JumpAnimSheet.set_frame(2)
		elif velocity.y <= -jump_force +jump_anim_count*5 and velocity.y >= -jump_force +jump_anim_count*4 :
			$JumpAnimSheet.set_frame(3)
		elif velocity.y <= -jump_force +jump_anim_count*6 and velocity.y >= -jump_force +jump_anim_count*5:
			$JumpAnimSheet.set_frame(4)
		elif velocity.y <= -jump_force +jump_anim_count*7 and velocity.y >= -jump_force +jump_anim_count*6:
			$JumpAnimSheet.set_frame(5)
		elif velocity.y >= -jump_force +jump_anim_count*7:
			$JumpAnimSheet.set_visible(false)
			$AnimatedSprite.set_visible(true)
			$AnimatedSprite.play("fall")
		


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump") else 1.0
		)
	  
	
func move():
	if direction.x == 0:
		velocity.x = 0
	elif Input.is_action_pressed("move_right"):
		velocity.x = min(velocity.x + acceration,max_speed)
	elif Input.is_action_pressed("move_left"):
		velocity.x = max(velocity.x - acceration,-max_speed)
	else:
		if velocity.x > 0:
			velocity.x = max(velocity.x - acceration,0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + acceration,0)
			
	
	
func jump():
	# coyote time
	if on_ground:
		_coyote_counter = coyote_time
	else :
		_coyote_counter -= get_physics_process_delta_time()
		
	# jump buffer
	if Input.is_action_just_pressed("jump") :
		_jump_buffer_counter = jump_buffer_time
	else :
		_jump_buffer_counter -=	get_physics_process_delta_time()
	
	# single jump
	if _coyote_counter > 0 and _jump_buffer_counter > 0 and jump_count == 0:
		velocity.y = -jump_force;
		_jump_buffer_counter = 0
		jump_count += 1
	# double jump
	elif jump_count == 1 and jump_count < 2 and Input.is_action_just_pressed("jump"):
		velocity.y = -double_jump_foce;
		_jump_buffer_counter = 0
		jump_count += 1
		 
	
	if velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = velocity.y * 0.5
		velocity.y += gravity * jump_cancel_mutiply * get_physics_process_delta_time()
			
	elif velocity.y > 0 and jump_count != 0:
		velocity.y += gravity * fall_mutiply * get_physics_process_delta_time()
		
	else :
		velocity.y += gravity * get_physics_process_delta_time()
		


func _spring_area_entered(area: Area2D) -> void:
	velocity.y = -400
	jump_count = 1
