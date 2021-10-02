extends Area2D

var state_machine : StateMachine
var element_state
var element_change_count = -1

var is_hit_left

export(Curve) var icefog_spread_curve


onready var anim_player = $AnimationPlayer

onready var collision_module = $MushroomCollision

onready var icefog_particle = $Icefog/Icice
onready var icefog_sprite = $Icefog/Icefog_sprite
onready var icefog_shape = $Icefog/Icefog_area/Icefog_triggershape

const N_IdleState = preload("res://Actors/Enemy/Mushroom/State/N_Idle.gd")
const I_IdleState = preload("res://Actors/Enemy/Mushroom/State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Enemy/Mushroom/State/F_Idle.gd")
const NtoFState = preload("res://Actors/Enemy/Mushroom/State/NtoF.gd")
const NtoIState = preload("res://Actors/Enemy/Mushroom/State/NtoI.gd")

func _ready():
	state_machine = StateMachine.new(N_IdleState.new(self))
	element_state = "Normal"


func _physics_process(delta):
	state_machine.update()
	pass

func _on_Hitbox_area_entered(area):
	
	if area.global_position.x > global_position.x:
		is_hit_left = false
	else :
		is_hit_left = true
	
	if element_change_count < 0:
		if area.owner.is_in_group("Ice"):
			match element_state:
				"Normal":
					state_machine.change_state(NtoIState.new(self))
				"Ice":
					pass
				"Fire":
					state_machine.change_state(N_IdleState.new(self))
					collision_module.change_to_normal_collision()
					element_state = "Normal"
		elif area.owner.is_in_group("Fire") or (area.owner.is_in_group("Slime") and area.owner.element_state == "Fire"):
			match element_state:
				"Normal":
					state_machine.change_state(NtoFState.new(self))
				"Ice":
					state_machine.change_state(N_IdleState.new(self))
					collision_module.change_to_normal_collision()
					element_state = "Normal"
				"Fire":
					pass
			

func NtoF_anim_end():
	state_machine.change_state(F_IdleState.new(self))
