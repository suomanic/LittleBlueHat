extends Node2D

onready var sprite = $Sprite

func _ready():
	owner = get_parent().owner
	
	pass

func _physics_process(delta):
	if owner.input_module.is_attack_just_pressed and get_parent().can_attack:
		$AnimationPlayer.play("attack")
	pass


func _on_SwordAttackArea_area_entered(area):
	if area.is_in_group("HurtBox"):
		print_debug("hit!")
	pass # Replace with function body.
