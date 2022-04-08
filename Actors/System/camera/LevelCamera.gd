extends Camera2D

var time = 1
var is_player_hurt_anim_playing
var player
onready var character_state_ui = $CharacterStateUI

onready var anim_player = $AnimationPlayer

export(Curve) var time_slow_curve


func _physics_process(delta):
	if time < 1 :
		time = min(time + delta , 1)
	Engine.time_scale = time_slow_curve.interpolate(time)
	
	
	if is_instance_valid(player):
		if player.movement_state_machine.is_state("Absorbed") and is_instance_valid(player.current_absorb_bubble):
			global_position = player.current_absorb_bubble.round()
		else:
			global_position = player.global_position.round()
		force_update_scroll()
	else:
		if get_tree().has_network_peer() \
			and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			if is_instance_valid(MultiplayerState.my_player_instance):
				player = get_tree().get_current_scene().get_node(MultiplayerState.my_player_instance.name)
		else:
			for c in get_tree().current_scene.get_children():
				if c.name.begins_with("Player"):
					player = c
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
