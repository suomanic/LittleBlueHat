extends Actor

var direction: = Vector2()

var state_machine : StateMachine

const IdleState = preload("res://Actors/Player/state/Idle.gd")
const RunState = preload("res://Actors/Player/state/Run.gd")
const FallState = preload("res://Actors/Player/state/Fall.gd")
const JumpState = preload("res://Actors/Player/state/Jump.gd")
const DoubleJumpState = preload("res://Actors/Player/state/DoubleJump.gd")
const CrouchState = preload("res://Actors/Player/state/Crouch.gd")

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
var is_crouch : = false

func _ready():
	state_machine = StateMachine.new(IdleState.new(self))

onready var anim_state_machine = $AnimationTree.get("parameters/playback")
onready var standing_collision = $Standing_Shape
onready var crouching_collision = $Crouching_Shape

func _physics_process(delta) -> void:
	state_machine.update()
	
	direction = get_direction()
	animation_control()
	move()
	jump()
	crouch()
	velocity = move_and_slide(velocity,Vector2.UP)
	
	if is_on_floor():
		on_ground = true
		jump_count = 0
	else:
		on_ground = false
		
	if is_on_floor() and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)
	
func apply_movement():
	pass
	
func animation_control():
	if direction.x > 0 :
		$AnimSpriteSheet.scale.x = 1
		$Particles2D.scale.x = 1
		$Particles2D.set_position(Vector2(-4,12))
	elif direction.x < 0 :
		$AnimSpriteSheet.scale.x = -1
		$Particles2D.scale.x = -1
		$Particles2D.set_position(Vector2(4,12))
	
	if	on_ground:
		$AnimationTree.active = true;
		$AnimationPlayer.stop(false)
		
		if velocity.x !=0 and !is_crouch:
			anim_state_machine.travel("Run_Anim")
			
		elif velocity.x == 0 and !is_crouch:
			anim_state_machine.travel("Idle_Anim")
			
		elif is_crouch:
			anim_state_machine.travel("CrouchIdle_Anim")
		
		
	# up to down animation bound to velocity.y
	elif !on_ground:
		var jump_anim_count = jump_force * 0.8 * 2/7
		var double_anim_count = jump_anim_count * 0.7
		
		$AnimationTree.active = false;
		
		if jump_count == 1:
			if velocity.y <= -jump_force +jump_anim_count:
				$AnimationPlayer.play("Up_Anim")
			else:
				$AnimationPlayer.stop(false)
				if velocity.y <= -jump_force +jump_anim_count*2 and velocity.y >= -jump_force +jump_anim_count:
					$AnimSpriteSheet.set_frame(0)
				elif velocity.y <= -jump_force +jump_anim_count*3 and velocity.y >= -jump_force +jump_anim_count*2:
					$AnimSpriteSheet.set_frame(1)
				elif velocity.y <= -jump_force +jump_anim_count*4 and velocity.y >= -jump_force +jump_anim_count*3:
					$AnimSpriteSheet.set_frame(2)
				elif velocity.y <= -jump_force +jump_anim_count*5 and velocity.y >= -jump_force +jump_anim_count*4 :
					$AnimSpriteSheet.set_frame(3)
				elif velocity.y <= -jump_force +jump_anim_count*6 and velocity.y >= -jump_force +jump_anim_count*5:
					$AnimSpriteSheet.set_frame(4)
				elif velocity.y <= -jump_force +jump_anim_count*7 and velocity.y >= -jump_force +jump_anim_count*6:
					$AnimSpriteSheet.set_frame(5)
				elif velocity.y <= -jump_force +jump_anim_count*8 and velocity.y >= -jump_force +jump_anim_count*7:
					$AnimSpriteSheet.set_frame(6)
				elif velocity.y >= -jump_force +jump_anim_count*8:
					$AnimationPlayer.play("Fall_Anim")
		elif jump_count == 2:
			$AnimationPlayer.stop(false)
			if velocity.y <= -jump_force +double_anim_count*2 and velocity.y >= -jump_force +double_anim_count:
				$AnimSpriteSheet.set_frame(37)
			elif velocity.y <= -jump_force +double_anim_count*3 and velocity.y >= -jump_force +double_anim_count*2:
				$AnimSpriteSheet.set_frame(38)
			elif velocity.y <= -jump_force +double_anim_count*4 and velocity.y >= -jump_force +double_anim_count*3:
				$AnimSpriteSheet.set_frame(39)
			elif velocity.y <= -jump_force +double_anim_count*5 and velocity.y >= -jump_force +double_anim_count*4 :
				$AnimSpriteSheet.set_frame(40)
			elif velocity.y <= -jump_force +double_anim_count*6 and velocity.y >= -jump_force +double_anim_count*5:
				$AnimSpriteSheet.set_frame(41)
			elif velocity.y <= -jump_force +double_anim_count*7 and velocity.y >= -jump_force +double_anim_count*6:
				$AnimSpriteSheet.set_frame(42)
			elif velocity.y <= -jump_force +double_anim_count*8 and velocity.y >= -jump_force +double_anim_count*7:
				$AnimSpriteSheet.set_frame(43)
			elif velocity.y >= -jump_force +double_anim_count*8:
				$AnimationPlayer.play("Fall_Anim")


func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump") else 1.0
		)
		
func _apply_gravity():
	if velocity.y < 0 and Input.is_action_just_released("jump"):
		velocity.y = velocity.y * 0.5
		velocity.y += gravity * jump_cancel_mutiply * get_physics_process_delta_time()			
	elif velocity.y > 0 and jump_count != 0:
		velocity.y += gravity * fall_mutiply * get_physics_process_delta_time()
		
	else :
		velocity.y += gravity * get_physics_process_delta_time()

func move():
	if direction.x == 0:
		if velocity.x > 0:
			velocity.x = max(velocity.x - deceleration,0)
		elif velocity.x < 0:
			velocity.x = min(velocity.x + deceleration,0)
	elif Input.is_action_pressed("move_right"):
		velocity.x = min(velocity.x + acceleration,max_speed)
	elif Input.is_action_pressed("move_left"):
		velocity.x = max(velocity.x - acceleration,-max_speed)
	
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
	
	# fall to double jump
	elif jump_count == 0 and _coyote_counter < 0 and !on_ground :
		jump_count = 1
		
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

func crouch():
	if Input.is_action_pressed("Crouch") and on_ground:
		is_crouch = true
		
	else :
		is_crouch = false
		

func _spring_area_entered(area: Area2D) -> void:
	velocity.y = -350
	jump_count = 1
