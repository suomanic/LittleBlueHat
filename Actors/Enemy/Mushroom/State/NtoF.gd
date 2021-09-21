extends State

func _init(o).(o):
	pass

func enter():
	if owner.is_hit_left:
		owner.anim_player.play("NtoF_Anim")
	else :
		owner.anim_player.play("NtoF_oppsite_Anim")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return ""
