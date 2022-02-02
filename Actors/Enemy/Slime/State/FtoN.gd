extends State

func _init(o).(o):
	pass

func enter():
	owner.can_change_element = false
	
	owner.anim_player.play("FtoN_Anim")
	owner.element_state = "Normal"
	owner.collision_module.FtoN_collision_change()
	
	owner.audio_player.stream = load("res://Assets/Audio/FtoN.wav")
	owner.audio_player.play()
	pass
	
func execute():
	pass

func exit():
	owner.can_change_element = true
	pass

static func get_name():
	return ""
