extends Node2D

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite
onready var player = get_parent().get_parent()
onready var bullet_data = {
	ice_bullet = preload("res://Actors/Player/Weapon/Bullet/IceBullet.tscn"),
	fire_bullet = preload("res://Actors/Player/Weapon/Bullet/FireBullet.tscn")
}

export onready var shoot_cd = 0.2
onready var shoot_cd_counter = 0

export onready var bullet_cpacity = 5
onready var current_cpacity = bullet_cpacity

func _ready():
	owner = get_parent().owner
	anim_player.play("Idle")
	

func _physics_process(delta):
	if owner.get_node("Character") != null:
		get_parent().follow_player()
	
	shoot_cd_counter -= delta
	
	if get_parent().owner.input_module.is_attack_just_pressed and shoot_cd_counter < 0:
		
		var bullet
		
		if node_name() == "FireMagicOrb":
			bullet = bullet_data.fire_bullet.instance()
		elif node_name() == "IceMagicOrb":
			bullet = bullet_data.ice_bullet.instance()
		
		var orb_position = get_parent().get_child(0).sprite.global_position
		var rotation_angle
		var position_x
	
	
		shoot_cd_counter = shoot_cd
		if player.get_node("Character").global_position.x - player.get_node("PlayerInput").mouse_global_position.x < 0:
			position_x = abs((player.get_node("PlayerInput").mouse_global_position - orb_position).x)
			rotation_angle = Vector2(position_x, player.get_node("PlayerInput").mouse_global_position.y - orb_position.y).angle()
		else:
			position_x = -abs((orb_position - player.get_node("PlayerInput").mouse_global_position).x)
			rotation_angle = Vector2(position_x, player.get_node("PlayerInput").mouse_global_position.y - orb_position.y).angle()
	
		bullet.global_position = orb_position
		bullet.rotate(rotation_angle)
		get_tree().get_root().add_child(bullet)
	pass

func node_name():
	return str(name.replace("@", "").replace(str(int(name)), ""))
