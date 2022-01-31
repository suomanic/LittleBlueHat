extends Node2D

onready var popup_content:Popup = get_node("MultiPlayerPopupMenu")

func _ready():
	pass

func _on_Teleport_area_entered(area):
	if area.owner.is_in_group('Player'):
		if get_tree().has_network_peer() \
			&& get_tree().network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
			return
		# 可能是因为bug，popup的位置如果为负值，弹出时会变为0，这里在弹出前先记录位置
		var temp_position = popup_content.rect_global_position
		popup_content.popup()
		popup_content.set_global_position(temp_position)
		popup_content.grab_focus()

func _on_Teleport_area_exited(area):
	if area.owner.is_in_group('Player'):
		popup_content.hide()
