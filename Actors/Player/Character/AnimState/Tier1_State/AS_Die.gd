extends State

func _init(o).(o):
	pass

func enter():
	owner.anim_sprite.set_visible(false)
	owner.die_sprite.set_visible(true)
	
	pass
	
func execute():
	owner.movement_anim_player.play("Die2_Anim")
	
	
	pass

func exit():
	owner.anim_sprite.set_visible(true)
	owner.die_sprite.set_visible(false)
	pass

func get_name():
	return "AS_Die"
