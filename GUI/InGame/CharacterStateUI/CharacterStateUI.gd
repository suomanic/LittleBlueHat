extends CanvasLayer

onready var container = $CharacterStateTextureRect
onready var hp1 = $CharacterStateTextureRect/Sprite
onready var hp2 = $CharacterStateTextureRect/Sprite2
onready var hp3 = $CharacterStateTextureRect/Sprite3
onready var hp4 = $CharacterStateTextureRect/Sprite4
onready var hps = [hp1, hp2, hp3, hp4]
onready var hp_on_ui = 4
var player

func _ready():
	container.set_visible(true)
	pass

func _physics_process(delta):
	if !is_instance_valid(player):
		if get_tree().has_network_peer() \
		and get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
			if is_instance_valid(MultiplayerState.my_player_instance):
				player = get_tree().get_current_scene().get_node(MultiplayerState.my_player_instance.name)
		else:
			for c in get_tree().current_scene.get_children():
				if c.name.begins_with("Player"):
					player = c
	health_down()
	
func health_down():
	if is_instance_valid(player):
		while hp_on_ui > player.hp and hp_on_ui > 0:
			hps[hp_on_ui-1].play_health_reduce_anim()
			hp_on_ui = hp_on_ui - 1
			
	pass
#todo: 气泡吸入bug（客户端吸入，服务端没吸入）
