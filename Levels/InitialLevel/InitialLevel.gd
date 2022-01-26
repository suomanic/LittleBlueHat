extends Node2D

onready var popup_content:Popup = get_node("MultiPlayerPopupMenu")

func _ready():
	pass

func _on_Teleport_area_entered(area):
	if area.owner.is_in_group('Player'):
		if get_tree().has_network_peer() \
			&& get_tree().network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
			return
		popup_content.popup()
		popup_content.grab_focus()

func _on_Teleport_area_exited(area):
	if area.owner.is_in_group('Player'):
		popup_content.hide()
