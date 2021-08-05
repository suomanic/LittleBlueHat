extends Node2D

onready var anim_player = $AnimationPlayer

func _onready():
	owner=get_parent().owner
	anim_player.play("Idle")


func _physics_process(delta):
	get_parent().follow_player()
	
	pass

