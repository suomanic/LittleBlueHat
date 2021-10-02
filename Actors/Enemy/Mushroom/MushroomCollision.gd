extends Node

func change_to_ice_collision():
	owner.icefog_particle.set_emitting(true)
	owner.icefog_sprite.set_visible(true)
	owner.icefog_shape.set_disabled(false)
	pass
	
func change_to_fire_collision():
	pass
	
func change_to_normal_collision():
	owner.icefog_particle.set_emitting(false)
	owner.icefog_sprite.set_visible(false)
	owner.icefog_shape.set_disabled(true)
	pass
