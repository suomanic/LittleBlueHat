extends Area2D

signal icefog_signal

var state_machine : StateMachine
var element_state
var can_change_element := true

var is_hit_left

export(Curve) var icefog_spread_curve

onready var audio_player = $AudioStreamPlayer2D
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
const ItoNState = preload("res://Actors/Enemy/Mushroom/State/ItoN.gd")
const FtoNState = preload("res://Actors/Enemy/Mushroom/State/FtoN.gd")

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
	
	if can_change_element:
		if area.owner.is_in_group("Ice"):
			match element_state:
				"Normal":
					state_machine.change_state(NtoIState.new(self))
				"Ice":
					pass
				"Fire":
					state_machine.change_state(FtoNState.new(self))
		elif area.owner.is_in_group("Fire") or (area.owner.is_in_group("Slime") and area.owner.element_state == "Fire"):
			match element_state:
				"Normal":
					state_machine.change_state(NtoFState.new(self))
				"Ice":
					state_machine.change_state(ItoNState.new(self))
				"Fire":
					pass
			

func inside_icefog():
	if can_change_element:
		match element_state:
			"Normal":
				state_machine.change_state(NtoIState.new(self))
			"Fire":
				state_machine.change_state(FtoNState.new(self))
	

func NtoF_anim_end():
	state_machine.change_state(F_IdleState.new(self))

func NtoI_anim_end():
	state_machine.change_state(I_IdleState.new(self))
	
func FtoN_anim_end():
	state_machine.change_state(N_IdleState.new(self))
	
func ItoN_anim_end():
	state_machine.change_state(N_IdleState.new(self))

func _on_Icefog_area_body_entered(body):
	print_debug(body)
	if body.is_in_group("CanChangeElement"):
		connect("icefog_signal",body,"inside_icefog")
	pass # Replace with function body.


func _on_Icefog_area_body_exited(body):
	if body.is_in_group("CanChangeElement"):
		disconnect("icefog_signal",body,"inside_icefog")
	pass # Replace with function body.


func _on_Icefog_area_area_entered(area):
	if area.is_in_group("CanChangeElement"):
		connect("icefog_signal",area,"inside_icefog")
	pass # Replace with function body.


func _on_Icefog_area_area_exited(area):
	if area.is_in_group("CanChangeElement"):
		disconnect("icefog_signal",area,"inside_icefog")
	pass # Replace with function body.


func emit_icefog_signal():
	emit_signal("icefog_signal")
