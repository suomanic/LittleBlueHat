extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_player.play("I_Idle_Anim")
	pass
	
func execute():
	owner.emit_icefog_signal()
	pass

func exit():
	pass

func get_name():
	return ""
