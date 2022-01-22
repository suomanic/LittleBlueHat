extends State

func _init(o).(o):
	pass

func enter():
	owner.effect_sprite.set_visible(true) 
	owner.bubble_anim_player.play("I_Idle_anim")
	owner.effect_anim_player.play("ice_effect_anim")
	owner.effect_anim_player.advance(owner.bubble_anim_player.get_current_animation_position())
	
	
	pass
	
func execute():
	pass

func exit():
	owner.effect_sprite.set_visible(false) 
	pass

static func get_name():
	return "I_Idle"
