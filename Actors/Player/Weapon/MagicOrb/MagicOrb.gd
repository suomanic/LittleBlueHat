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
	shoot_cd_counter -= delta

	pass

func attack():
	var bullet
	var audio_player = AudioStreamPlayer2D.new()
	
	if node_name() == "FireMagicOrb":
		audio_player.stream = load("res://Assets/Audio/fire_bullet_shot.wav")
		bullet = bullet_data.fire_bullet.instance()
	elif node_name() == "IceMagicOrb":
		audio_player.stream = load("res://Assets/Audio/ice_shoot.wav")
		bullet = bullet_data.ice_bullet.instance()
	
	get_tree().get_root().add_child(audio_player)
	audio_player.play()
	if !audio_player.playing:
		audio_player.queue_free()
	
	var orb_position = get_parent().get_child(0).sprite.global_position
	var rotation_angle
	var position_x

	shoot_cd_counter = shoot_cd
	if orb_position.x - player.global_position.x < 0:
		position_x = -abs(orb_position.x - player.global_position.x)
		rotation_angle = Vector2(position_x, orb_position.y - player.global_position.y).angle()
	else:
		position_x = abs(orb_position.x - player.global_position.x)
		rotation_angle = Vector2(position_x, orb_position.y - player.global_position.y).angle()

	bullet.global_position = orb_position
	bullet.rotate(rotation_angle)
	get_tree().get_root().add_child(bullet)


func node_name():
	return str(name.replace("@", "").replace(str(int(name)), ""))
