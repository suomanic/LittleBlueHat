extends Area2D

signal absorb_signal

var state_machine : StateMachine

onready var anim_player = $AnimationPlayer
onready var bubble_sprite = $BubbleSprite
onready var arrow_sprite = $ArrowSprite

onready var enter_shape = $EnterShape
onready var time = 0 
onready var character
onready var absolute_position = global_position

const freeState = preload("res://Actors/Item/Bubble/State/Tier_1_State/Free.gd")
const occupiedState = preload("res://Actors/Item/Bubble/State/Tier_1_State/Occupied.gd")

export var absorb_curve : Curve

func _ready():
	state_machine = StateMachine.new(freeState.new(self))

func _physics_process(delta):
	state_machine.update()
	
	time += delta
	
	if character != null:
		bubble_sprite.global_position = lerp(absolute_position,character.global_position,absorb_curve.interpolate(time))
	pass

func arrow_sprite_movement():
	arrow_sprite.global_position = (get_global_mouse_position() - bubble_sprite.global_position).normalized() * 25 + bubble_sprite.global_position
	arrow_sprite.rotation = (get_global_mouse_position() - bubble_sprite.global_position).angle() + PI/2

func _on_Bubble_body_entered(body):
	if body.is_in_group("Player"):
		character = body 
		connect("absorb_signal",body,"absorbed_by_bubble")
		emit_signal("absorb_signal",global_position)
		time = 0
	
	state_machine.change_state(occupiedState.new(self))
	

func _on_Bubble_body_exited(body):
	# todo
	state_machine.change_state(freeState.new(self))
	
	if body.is_in_group("Player"):
		disconnect("absorb_signal",body,"absorbed_by_bubble")
	pass # Replace with function body.
