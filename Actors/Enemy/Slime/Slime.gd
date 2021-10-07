extends Actor

var state_machine : StateMachine
var element_state : String

var can_change_element := true

var can_cause_squish_damage
var player

#元素状态在编辑器中操作
enum DROPOFF { fire,normal,ice }
export(DROPOFF) var element

const N_IdleState = preload("res://Actors/Enemy/Slime/State/N_Idle.gd")
const I_IdleState = preload("res://Actors/Enemy/Slime/State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Enemy/Slime/State/F_Idle.gd")

const N_MoveState = preload("res://Actors/Enemy/Slime/State/N_Move.gd")
const F_WanderState = preload("res://Actors/Enemy/Slime/State/F_Wander.gd")
const F_ChaseState = preload("res://Actors/Enemy/Slime/State/F_Chase.gd")

const NtoIState = preload("res://Actors/Enemy/Slime/State/NtoI.gd")
const ItoNState = preload("res://Actors/Enemy/Slime/State/ItoN.gd")
const NtoFState = preload("res://Actors/Enemy/Slime/State/NtoF.gd")
const FtoNState = preload("res://Actors/Enemy/Slime/State/FtoN.gd")


onready var anim_player = $AnimationPlayer

onready var f_ray_cast = $FrontRayCast
onready var b_ray_cast = $BackRayCast

#着地检测
onready var r_ground_ray_cast = $RightGroundRaycast
onready var l_ground_ray_cast = $LeftGroundRaycast

onready var sprite_sheet = $AnimationSheet

onready var collision_module = $SlimeCollision
onready var movement_module = $SlimeMovement

onready var physic_collsion = $PhysicCollision
onready var squish_collsion = $SquishHitBox/CollisionShape2D
onready var hit_collision = $HitBox/CollisionShape2D
onready var player_detectshape = $PlayerDetector/PlayerDetectShape

onready var SDM_Timer = $SquishDamageMoveTimer

func _ready():
	#将每个对象的物理碰撞独立出来
	get_node("PhysicCollision").shape = get_node("PhysicCollision").shape.duplicate()
	
	state_machine = StateMachine.new(N_MoveState.new(self))
	element_state = "Normal"
	
	#初始化元素状态
	match element:
		DROPOFF.fire:
			physic_collsion.call_deferred("change_to_fire_collision_box")
			state_machine.change_state(F_IdleState.new(self))
			element_state = "Fire"
		DROPOFF.normal:
			physic_collsion.call_deferred("change_to_normal_collision_box")
			state_machine.change_state(N_IdleState.new(self))
			element_state = "Normal"
		DROPOFF.ice:
			physic_collsion.call_deferred("change_to_ice_collision_box")
			state_machine.change_state(I_IdleState.new(self))
			element_state = "Ice"
	
	player_detectshape.disabled = true
	
func _physics_process(delta):
	state_machine.update()
	
	switch_can_cause_squish_damage()
	
	if movement_module.is_moving_finished and can_change_element and (element_state == "Fire") and player != null:
		state_machine.change_state(F_ChaseState.new(self))
	
func _turn_around():
	if movement_module.is_moving_finished and movement_module.is_on_object:
		movement_module.is_moving_left = !movement_module.is_moving_left
		scale.x = -scale.x

func _on_HitBox_area_entered(area):
	if can_change_element:
		if area.get_owner().is_in_group("Ice"):
			print_debug("ice damage")
#			if area.get_owner().get_owner().is_in_group("Player"):
#				if global_position.x - area.owner.owner.get_node("Character").global_position.x > 0:
#					movement_module.is_hurt_move_left = true
#				elif global_position.x - area.owner.owner.owner.get_node("Character").global_position.x < 0:
#					movement_module.is_hurt_move_left = false
			match element_state:
				"Normal":
					state_machine.change_state(NtoIState.new(self))
				"Ice":
					anim_player.play("I_Shake_Anim")
				"Fire":
					state_machine.change_state(FtoNState.new(self))
		elif area.owner.is_in_group("Fire"):
			print_debug("fire damage")
			match element_state:
				"Normal":
					state_machine.change_state(NtoFState.new(self))
				"Ice":
					state_machine.change_state(ItoNState.new(self))
				"Fire":
					pass
			
	pass # Replace with function body.

func normal_to_ice_end():
	state_machine.change_state(I_IdleState.new(self))

func normal_to_fire_end():
	state_machine.change_state(F_IdleState.new(self))

func ice_to_normal_end():
	state_machine.change_state(N_IdleState.new(self))
	
func fire_to_normal_end():
	state_machine.change_state(N_IdleState.new(self))
	
	
func _on_PlayerDetector_body_entered(body):
	if body.is_in_group("Player") :
		player = body
	pass # Replace with function body.

func _on_PlayerDetector_body_exited(body):
	print_debug("player gone")
	if body.is_in_group("Player") :
		player = null
	pass


func switch_can_cause_squish_damage():
	if movement_module.gravity > 0 and element_state == "Ice":
		can_cause_squish_damage = true
	else:
		can_cause_squish_damage = false


func inside_icefog():
	if can_change_element:
		match element_state:
			"Normal":
				state_machine.change_state(NtoIState.new(self))
			"Fire":
				state_machine.change_state(FtoNState.new(self))
