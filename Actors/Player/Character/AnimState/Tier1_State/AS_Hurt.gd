extends State

func _init(o).(o):
	pass

func enter():
	owner.movement_anim_player.play("Hurt_Anim")
	owner.effect_anim_player.play("Invincible_Effect_Anim")
	owner.get_tree().call_group("LevelCamera","player_hurt")
	pass
	
func execute():
	pass

func exit():
	pass

func get_name():
	return ""
