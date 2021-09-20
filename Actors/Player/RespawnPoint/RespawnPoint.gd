extends Node2D
onready var respawn_timer = $RespawnTimer

func respawn():
	respawn_timer.set_wait_time(2)
	respawn_timer.start()
	pass

func _on_RespawnTimer_timeout():
	respawn_timer.stop()
	get_tree().reload_current_scene()
	pass # Replace with function body.
