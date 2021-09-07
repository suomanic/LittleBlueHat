extends RigidBody2D

var state_machine : StateMachine
var is_moving_left := true
var is_hurt_move_left := true
var element_state : String
var is_moving_finished := false

var element_change_time = 0.5
var element_change_count = -1

var player

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
onready var sprite_sheet = $AnimationSheet

onready var collision_module = $SlimeCollision
onready var movement_module = $SlimeMovement

onready var physic_collsion = $PhysicCollision
onready var hit_collision = $HitBox/CollisionShape2D
onready var player_detectshape = $PlayerDetector/PlayerDetectShape

func _ready():
	#将每个对象的物理碰撞独立出来
	get_node("PhysicCollision").shape = get_node("PhysicCollision").shape.duplicate()
	
	state_machine = StateMachine.new(N_MoveState.new(self))
	element_state = "Normal"
	
	player_detectshape.disabled = true
	
func _physics_process(delta):
	element_change_count -= delta
	
	if is_moving_finished and element_change_count < 0 and (element_state == "Fire") and player != null:
		state_machine.change_state(F_ChaseState.new(self))

func _integrate_forces(state) -> void:
	movement_module.gravity()
	state_machine.update()
	
#备用
#func _integrate_forces(state) -> void:
#	var is_on_ground = state.get_contact_count() > 0 and int(state.get_contact_collider_position(0).y) >= int(global_position.y)	
	
func _turn_around():
	is_moving_left = !is_moving_left
	# 二维刚体在直接设置scale.x时会出现问题
	# 详见https://github.com/godotengine/godot/issues/12335
	# 这里暂时暴力将所有含有scale属性的子实例的scale.x置反，等待引擎解决问题	
	for child in get_children():
		if child.get("scale") != null:
			child.scale.x = -child.scale.x
			child.position.x = -child.position.x


func _on_HitBox_area_entered(area):
	if element_change_count < 0:
		if area.get_owner().is_in_group("Ice"):
			print_debug("ice damage")
			if area.get_owner().is_in_group("Player"):
				if global_position.x - area.owner.owner.get_node("Character").global_position.x > 0:
					is_hurt_move_left = true
				elif global_position.x - area.owner.owner.get_node("Character").global_position.x < 0:
					is_hurt_move_left = false
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
