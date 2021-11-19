extends Area2D

signal absorb_signal

var state_machine : StateMachine

var eject_angle
var absorb_direction := false  #true为右，false为左
var eject_direction := false  #true为右，false为左

onready var bubble_anim_player = $BubbleAnimationPlayer
onready var arrow_anim_player = $ArrowAniamtionPlayer
onready var character_shadow_anim_player = $CharacterShadowAnimationPlayer

onready var bubble_sprite = $BubbleSprite
onready var arrow_sprite = $ArrowSprite
onready var character_shadow_sprite = $CharacterShadowSprite

onready var enter_shape = $EnterShape
onready var character
onready var absolute_position = global_position

onready var label = $Label

const freeState = preload("res://Actors/Item/Bubble/State/Tier_1_State/Free.gd")
const occupiedState = preload("res://Actors/Item/Bubble/State/Tier_1_State/Occupied.gd")
const ejectState = preload("res://Actors/Item/Bubble/State/Tier_1_State/Eject.gd")

export var absorb_curve : Curve
export var eject_curve : Curve


func _ready():
	state_machine = StateMachine.new(freeState.new(self))

func _physics_process(delta):
	state_machine.update()
	eject_angle = (get_global_mouse_position() - bubble_sprite.global_position).angle()
	
	character_shadow_sprite.global_position = bubble_sprite.global_position
	
	if state_machine.current_state != null:
		label.text = state_machine.current_state.get_name()
	
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
	state_machine.change_state(occupiedState.new(self))
	
func disconnect_absorb_signal():
	disconnect("absorb_signal",character,"absorbed_by_bubble")

func anim_called_character_shadow_to_idle():
	character_shadow_anim_player.play("idle_anim")
