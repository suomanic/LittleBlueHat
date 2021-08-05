extends Node2D

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

onready var bullet_data = preload("res://Actors/Player/Weapon/Bullet/Bullet.tscn")


func _ready():
	anim_player.play("Idle")

func _physics_process(delta):
	get_parent().follow_player()
	
	if get_parent().owner.input_module.is_attack_just_pressed:
		
		var bullet = bullet_data.instance()
		var orb_position = get_parent().get_child(0).sprite.global_position
		var rotation_angle = (get_parent().owner.input_module.mouse_global_position - orb_position).angle()
		
		bullet.global_position = orb_position
		bullet.rotate(rotation_angle)
		
		get_tree().get_root().add_child(bullet)
	pass

