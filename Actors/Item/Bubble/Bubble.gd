extends Area2D

signal absorb_signal

onready var anim_player = $AnimationPlayer
onready var sprite = $BubbleSprite
onready var enter_shape = $EnterShape
onready var time = 0 
onready var player
onready var absolute_position = global_position

export var absorb_curve : Curve

func _ready():
	anim_player.play("N_Idle_anim")

func _physics_process(delta):
	time += delta
	
	if player != null:
		sprite.global_position = lerp(absolute_position,player.global_position,absorb_curve.interpolate(time))
	pass


func _on_Bubble_body_entered(body):
	if body.is_in_group("Player"):
		player = body 
		connect("absorb_signal",body,"absorbed_by_bubble")
		emit_signal("absorb_signal",global_position)
		time = 0
		print_debug("enter bubble")
		

