extends State

func _init(o).(o):
	pass

func enter():
	owner.collision_module.change_to_fire_collision()
	owner.element_state = "Fire"
	
	owner.can_change_element = false
	
	if owner.is_hit_left:
		owner.anim_player.play("NtoF_Anim")
	else :
		owner.anim_player.play("NtoF_oppsite_Anim")
	pass
	
	owner.audio_player.stream = load("res://Assets/Audio/mushroom_fire.wav")
	owner.audio_player.play()
	
func execute():
	
	pass

func exit():
	owner.can_change_element = true
	pass

static func get_name():
	return "NtoF"
