extends Actor

var direction: = Vector2()

var state_machine : StateMachine

const IdleState = preload("res://Actors/Player/state/Idle.gd")
const RunState = preload("res://Actors/Player/state/Run.gd")
const FallState = preload("res://Actors/Player/state/Fall.gd")
const JumpState = preload("res://Actors/Player/state/Jump.gd")
const DoubleJumpState = preload("res://Actors/Player/state/DoubleJump.gd")
const CrouchState = preload("res://Actors/Player/state/Crouch.gd")
const UpState = preload("res://Actors/Player/state/Up.gd")

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

var jump_anim_count = jump_force * 0.8 * 2/7
var double_anim_count = jump_anim_count * 0.7

onready var anim_state_machine = $AnimationTree.get("parameters/playback")
onready var standing_collision = $Standing_Shape
onready var crouching_collision = $Crouching_Shape

onready var animation_tree = $AnimationTree
onready var animation_player = $AnimationPlayer
onready var animation_sprite_sheet = $AnimSpriteSheet

func _ready():
	state_machine = StateMachine.new(IdleState.new(self))

func _physics_process(delta) -> void:
	state_machine.update()
	
	direction = get_direction()
	apply_gravity()
	animation_control()
	crouch()
	velocity = move_and_slide(velocity,Vector2.UP)
	
	if is_on_floor():
		_coyote_counter = coyote_time
	else :
		_coyote_counter -= delta
		
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_counter = jump_buffer_time
	else:
		_jump_buffer_counter -= delta
	
	if is_on_floor():
		on_ground = true
		jump_count = 0
	else:
		on_ground = false
		
	if is_on_floor() and velocity.x != 0:
		$Particles2D.set_emitting(true)
	else :
		$Particles2D.set_emitting(false)
	
func get_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right")-Input.get_action_strength("move_left"),
		-1.0 if Input.is_action_pressed("jump") else 1.0
		)
	
func animation_control():
	if direction.x > 0 :
		$AnimSpriteSheet.scale.x = 1
		$Particles2D.scale.x = 1
		$Particles2D.set_position(Vector2(-4,12))
	elif direction.x < 0 :
		$AnimSpriteSheet.scale.x = -1
		$Particles2D.scale.x = -1
		$Particles2D.set_position(Vector2(4,12))
	
			

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
	
func apply_gravity():
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
