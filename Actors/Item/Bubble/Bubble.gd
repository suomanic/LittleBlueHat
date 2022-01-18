extends Area2D

signal absorb_signal

var behavior_state_machine : StateMachine
var element_state_machine : StateMachine

var element_state : String
var can_change_element := true

var eject_angle
var absorb_direction := false  #true为右，false为左
var eject_direction := false  #true为右，false为左

onready var bubble_anim_player = $BubbleAnimationPlayer
onready var arrow_anim_player = $ArrowAniamtionPlayer
onready var character_shadow_anim_player = $CharacterShadowAnimationPlayer
onready var effect_anim_player = $EffectAnimationPlayer

onready var bubble_sprite = $BubbleSprite
onready var arrow_sprite = $BubbleSprite/ArrowSprite
onready var character_shadow_sprite = $BubbleSprite/CharacterShadowSprite
onready var effect_sprite = $BubbleSprite/EffectSprite

onready var normal_position = $NormalPostion
onready var ice_position = $IcePostion
onready var fire_position = $FirePostion

onready var enter_shape = $EnterShape
onready var character
onready var absolute_position = global_position

onready var label = $Label
onready var label2 = $Label2

#behavior state
const freeState = preload("res://Actors/Item/Bubble/State/Behavior_State/Free.gd")
const occupiedState = preload("res://Actors/Item/Bubble/State/Behavior_State/Occupied.gd")
const ejectState = preload("res://Actors/Item/Bubble/State/Behavior_State/Eject.gd")

#element state
const I_IdleState = preload("res://Actors/Item/Bubble/State/Element_State/I_Idle.gd")
const F_IdleState = preload("res://Actors/Item/Bubble/State/Element_State/F_Idle.gd")
const N_IdleState = preload("res://Actors/Item/Bubble/State/Element_State/N_Idle.gd")
const ItoNState = preload("res://Actors/Item/Bubble/State/Element_State/ItoN.gd")
const NtoIState = preload("res://Actors/Item/Bubble/State/Element_State/NtoI.gd")
const FtoNState = preload("res://Actors/Item/Bubble/State/Element_State/FtoN.gd")
const NtoFState = preload("res://Actors/Item/Bubble/State/Element_State/NtoF.gd")


export var absorb_curve : Curve
export var eject_curve : Curve


func _ready():
	behavior_state_machine = StateMachine.new(freeState.new(self))
	element_state_machine = StateMachine.new(N_IdleState.new(self))

func _physics_process(delta):
	behavior_state_machine.update()
	element_state_machine.update()
	
	eject_angle = (get_global_mouse_position() - bubble_sprite.global_position).angle()
	
	
	if behavior_state_machine.current_state != null:
		label.text = behavior_state_machine.current_state.get_name()
	if element_state_machine.current_state != null:
		label2.text = element_state_machine.current_state.get_name()	
		
	if absorb_direction :
		character_shadow_sprite.scale.x = 1
	else : 
		character_shadow_sprite.scale.x = -1
		
	
func arrow_sprite_movement():
	arrow_sprite.global_position = (get_global_mouse_position() - bubble_sprite.global_position).normalized() * 25 + bubble_sprite.global_position
	arrow_sprite.rotation = (get_global_mouse_position() - bubble_sprite.global_position).angle() + PI/2


func _on_Bubble_body_entered(body):
	if body.is_in_group("Player"):
		if body.collision_module.facing():
			absorb_direction = true
		else :
			absorb_direction = false
		
		character = body 
		connect("absorb_signal",body,"absorbed_by_bubble")
		emit_signal("absorb_signal",global_position)
	behavior_state_machine.change_state(occupiedState.new(self))
	
func disconnect_absorb_signal():
	disconnect("absorb_signal",character,"absorbed_by_bubble")

func anim_called_character_shadow_to_idle():
	character_shadow_anim_player.play("idle_anim")
	character_shadow_anim_player.advance(bubble_anim_player.current_animation_position)


func _on_Hitbox_area_entered(area):
	print_debug(area)
	if can_change_element:
		if area.get_owner().is_in_group("Ice"):
			match element_state:
				"Normal":
					element_state_machine.change_state(NtoIState.new(self))
					pass
				"Ice":
					#anim_player.play("I_Shake_Anim")
					pass
				"Fire":
					pass
					#element_state_machine.change_state(FtoNState.new(self))
		elif area.owner.is_in_group("Fire"):
			print_debug("fire damage")
			match element_state:
				"Normal":
					#element_state_machine.change_state(NtoFState.new(self))
					pass
				"Ice":
					element_state_machine.change_state(ItoNState.new(self))
					pass
				"Fire":
					pass
			
	pass # Replace with function body.
