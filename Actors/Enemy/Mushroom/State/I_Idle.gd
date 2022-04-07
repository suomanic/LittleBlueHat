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

static func get_name():
	return "I_Idle"
