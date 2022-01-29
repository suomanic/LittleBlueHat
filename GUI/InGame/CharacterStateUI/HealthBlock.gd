extends Sprite

onready var anim_player = $AnimationPlayer

func _ready():
	pass

func play_health_reduce_anim():
	anim_player.play("disappear")
	
func play_health_increase_anim():
	pass
