tool
extends Area2D

signal absorb_signal

var behavior_state_machine : StateMachine
var element_state_machine : StateMachine
var movement_state_machine : StateMachine

var element_state : String
var can_change_element := true
var move_target

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

onready var enter_shape = $EnterShape
onready var player

onready var label = $Label
onready var label2 = $Label2
onready var label3 = $Label3
onready var label4 = $Label4

#movement state
const moveState = preload("res://Actors/Item/Bubble/State/Movement_State/Move.gd")
const idleState = preload("res://Actors/Item/Bubble/State/Movement_State/Idle.gd")

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
export var move_curve : Curve

export var move_speed := 50

#不同状态下泡泡的目标绝对位置
onready var normal_absolute_position 
onready var ice_absolute_position 
onready var fire_absolute_position 

export var normal_pos : Vector2
export var fire_pos : Vector2
export var ice_pos : Vector2

func _ready():
	if not Engine.editor_hint:
		behavior_state_machine = StateMachine.new(freeState.new(self))
		element_state_machine = StateMachine.new(N_IdleState.new(self))
		movement_state_machine = StateMachine.new(idleState.new(self))

		normal_absolute_position = global_position + normal_pos
		ice_absolute_position = global_position + ice_pos
		fire_absolute_position = global_position + fire_pos
	
func _physics_process(delta):
	if  Engine.editor_hint: #只在编辑器中运行的代码，用于在编辑器中显示不同元素下泡泡的目标位置
		get_node("NormalPosition").position = normal_pos
		get_node("IcePosition").position = ice_pos
		get_node("FirePosition").position = fire_pos
	
	
	if not Engine.editor_hint: #只在游戏中运行的代码
		behavior_state_machine.update()
		element_state_machine.update()
		movement_state_machine.update()
		
		eject_angle = (get_global_mouse_position() - bubble_sprite.global_position).angle()
		
		if behavior_state_machine.current_state != null:
			label.text = behavior_state_machine.current_state.get_name()
		if element_state_machine.current_state != null:
			label2.text = element_state_machine.current_state.get_name()	
		label4.text = String(global_position.y)
			
		if absorb_direction :
			character_shadow_sprite.scale.x = 1
		else : 
			character_shadow_sprite.scale.x = -1
			
	
func arrow_sprite_movement():
	if not Engine.editor_hint: 
		arrow_sprite.global_position = (get_global_mouse_position() - bubble_sprite.global_position).normalized() * 25 + bubble_sprite.global_position
		arrow_sprite.rotation = (get_global_mouse_position() - bubble_sprite.global_position).angle() + PI/2


func _on_Bubble_body_entered(body):
	if not Engine.editor_hint: 
		if body.is_in_group("Player"):
			if body.collision_module.facing():
				absorb_direction = true
			else :
				absorb_direction = false
			
			player = body 
			connect("absorb_signal",body,"absorbed_by_bubble")
			emit_signal("absorb_signal",self)
		behavior_state_machine.change_state(occupiedState.new(self))
	
func disconnect_absorb_signal():
	if not Engine.editor_hint: 
		disconnect("absorb_signal",player,"absorbed_by_bubble")

func anim_called_character_shadow_to_idle():
	if not Engine.editor_hint: 
		character_shadow_anim_player.play("idle_anim")
		character_shadow_anim_player.advance(bubble_anim_player.current_animation_position)

func _on_Hitbox_area_entered(area):
	if not Engine.editor_hint: 
		if can_change_element:
			if area.get_owner().is_in_group("Ice"): 
				match element_state:
					"Normal":
						element_state_machine.change_state(NtoIState.new(self))
						movement_state_machine.change_state(moveState.new(self))
					"Ice":
						pass
					"Fire":
						element_state_machine.change_state(FtoNState.new(self))
						movement_state_machine.change_state(moveState.new(self))
			elif area.owner.is_in_group("Fire"): 
				match element_state:
					"Normal":
						element_state_machine.change_state(NtoFState.new(self))
						movement_state_machine.change_state(moveState.new(self))
					"Ice":
						element_state_machine.change_state(ItoNState.new(self))
						movement_state_machine.change_state(moveState.new(self))
					"Fire":
						pass
				
		pass # Replace with function body.


