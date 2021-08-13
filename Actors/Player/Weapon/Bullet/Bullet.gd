extends KinematicBody2D

onready var anim_player = $AnimationPlayer

var velocity : Vector2

func _ready():
	anim_player.play("Spawn_Anim")
	var direction = Vector2(cos(rotation),sin(rotation))
	
	velocity = 200 * direction
	pass

func _physics_process(delta):
	velocity = move_and_slide(velocity,Vector2.UP)
	pass

func _anim_call_anim():
	anim_player.play("Spin_Anim")

func _on_Hitbox_area_entered(area):
	if area.is_in_group("Hitbox"):
		queue_free()


func _on_Hitbox_body_entered(body):
	if body is TileMap:
		queue_free()
