extends Area2D

onready var popup_content:Popup = get_node("MultiPlayerPopupMenu")

func _ready():
	pass


func _on_Teleport_body_entered(body):
	if body.is_in_group('Player'):
		if get_tree().has_network_peer() \
			&& get_tree().network_peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
			return
		# 可能是因为bug，popup的位置会自动设置为(0,0)
		popup_content.popup()
		popup_content.rect_global_position = Vector2(self.position.x - popup_content.rect_size.x * popup_content.rect_scale.x / 2, self.position.y - $TeleportSprite.get_rect().size.y / 2 - popup_content.rect_size.y * popup_content.rect_scale.y)
		popup_content.grab_focus()


func _on_Teleport_body_exited(body):
	if body.is_in_group('Player'):
		popup_content.hide()
