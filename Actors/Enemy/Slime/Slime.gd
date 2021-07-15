extends RigidBody2D

var state_machine : StateMachine
var is_moving_left := true
var is_hurt_move_left := true
var moving_finished := false
var element_state : String

const N_IdleState = preload("res://Actors/Enemy/Slime/State/N_Idle.gd")
const I_IdleState = preload("res://Actors/Enemy/Slime/State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Enemy/Slime/State/F_Idle.gd")

const N_MoveState = preload("res://Actors/Enemy/Slime/State/N_Move.gd")
const F_MoveState = preload("res://Actors/Enemy/Slime/State/F_Move.gd")

const NtoIState = preload("res://Actors/Enemy/Slime/State/NtoI.gd")
const ItoNState = preload("res://Actors/Enemy/Slime/State/ItoN.gd")
const NtoFState = preload("res://Actors/Enemy/Slime/State/NtoF.gd")


onready var anim_player = $AnimationPlayer
onready var f_ray_cast = $FrontRayCast
onready var b_ray_cast = $BackRayCast
onready var sprite_sheet = $AnimationSheet

onready var collision_module = $SlimeCollision
onready var movement_module = $SlimeMovement

onready var physic_collsion = $PhysicCollision
onready var hit_collision = $HitBox/CollisionShape2D

func _ready():
	#将每个对象的物理碰撞独立出来
	get_node("PhysicCollision").shape = get_node("PhysicCollision").shape.duplicate()

	state_machine = StateMachine.new(N_MoveState.new(self))
	element_state = "Normal"
	
func _physics_process(delta):
	pass

func _integrate_forces(state) -> void:
	state_machine.update()
	_turn_around()
	
	
#备用
#func _integrate_forces(state) -> void:
#	var is_on_ground = state.get_contact_count() > 0 and int(state.get_contact_collider_position(0).y) >= int(global_position.y)	
	
func _turn_around():
	if f_ray_cast.is_colliding() and moving_finished and !b_ray_cast.is_colliding():
		is_moving_left = !is_moving_left
		
		# 二维刚体在直接设置scale.x时会出现问题
		# 详见https://github.com/godotengine/godot/issues/12335
		# 这里暂时暴力将所有含有scale属性的子实例的scale.x置反，等待引擎解决问题
		for child in get_children():
			if child.get("scale") != null:
				child.scale.x = -child.scale.x
				child.position.x = -child.position.x
	pass

func _hurt_end():
	state_machine.change_state(I_IdleState.new(self))

func _on_HitBox_area_entered(area):
	if area.owner.is_in_group("Ice"):
		print_debug("ice damage")
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
				state_machine.change_state(N_IdleState.new(self))
				emit_signal("change_to_normal")
				element_state = "Normal"
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

func normal_to_fire_end():
	state_machine.change_state(F_IdleState.new(self))

func ice_to_normal_end():
	state_machine.change_state(N_IdleState.new(self))
	

func _on_Slime_sleeping_state_changed():
	print_debug("sleep state changed")
	print_debug(is_sleeping())
