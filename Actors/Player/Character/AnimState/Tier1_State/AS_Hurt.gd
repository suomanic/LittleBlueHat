extends State

func _init(o).(o):
	pass

func enter():
	
	owner.movement_anim_player.play("Hurt_Anim")
	owner.effect_anim_player.play("Invincible_Effect_Anim")
	owner.get_tree().call_group("LevelCamera","player_hurt")
	pass
	
func execute():
	
	if owner.hp <= 0 :
		owner.anim_state_machine.change_state(owner.AS_DieState.new(owner))
	pass

func exit():
	pass

static func get_name():
	return "AS_Hurt"
	
