extends Camera2D

var time = 1
var is_player_hurt_anim_playing
var player 

onready var anim_player = $AnimationPlayer

export(Curve) var time_slow_curve

	

func _physics_process(delta):
	if time < 1 :
		time = min(time + delta , 1)
	Engine.time_scale = time_slow_curve.interpolate(time)
	
	player = get_tree().get_current_scene().get_node("Player")
	if player != null:
		global_position = player.global_position
	else:
		player = get_tree().get_current_scene().get_node("Player")

func player_hurt():
	camera_zoom_in()
	

func camera_zoom_in():
	anim_player.play("Zoom_In_Anim")
	pass
	
func anim_start():
	time = 0
	is_player_hurt_anim_playing = true
	

func anim_end():
	is_player_hurt_anim_playing = false
