extends Node2D

onready var anim_player = $AnimationPlayer
onready var sprite = $Sprite

onready var bullet_data = {
	ice_bullet = preload("res://Actors/Player/Weapon/Bullet/IceBullet.tscn"),
	fire_bullet = preload("res://Actors/Player/Weapon/Bullet/FireBullet.tscn")
}


func _ready():
	owner = get_parent().owner
	anim_player.play("Idle")

func _physics_process(delta):
	if owner.get_node("Character") != null:
		get_parent().follow_player()
	
	if get_parent().owner.input_module.is_attack_just_pressed:
		
		var bullet
		
		if node_name() == "FireMagicOrb":
			bullet = bullet_data.fire_bullet.instance()
		elif node_name() == "IceMagicOrb":
			bullet = bullet_data.ice_bullet.instance()
		
		var orb_position = get_parent().get_child(0).sprite.global_position
		var rotation_angle = (get_parent().owner.input_module.mouse_global_position - orb_position).angle()
		
		bullet.global_position = orb_position
		bullet.rotate(rotation_angle)
		
		get_tree().get_root().add_child(bullet)
	pass

func node_name():
	return str(name.replace("@", "").replace(str(int(name)), ""))
