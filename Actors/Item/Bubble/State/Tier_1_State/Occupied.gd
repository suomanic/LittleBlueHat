extends State

func _init(o).(o):
	pass

func enter():
	owner.arrow_sprite.set_visible(true)
	pass
	
func execute():
	owner.arrow_sprite_movement()
	
	if owner.character.get_parent().input_module.is_attack_just_pressed:
		pass
	
	pass

func exit():
	owner.arrow_sprite.set_visible(false)
	pass

func get_name():
	return "Occupied"
