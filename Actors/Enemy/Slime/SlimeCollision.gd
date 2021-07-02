extends Node

func _ready():
	pass

func change_ice_collision():
	owner.physic_collsion.call_deferred("change_to_ice_collision_box")

func change_fire_collision():
	owner.physic_collsion.call_deferred("change_to_fire_collision_box")

func ItoN_collision_change():
	owner.physic_collsion.call_deferred("change_to_normal_collision_box")
