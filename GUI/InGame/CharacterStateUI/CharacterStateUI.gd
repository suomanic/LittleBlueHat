extends CanvasLayer

onready var container = $CharacterStateTextureRect
onready var hp1 = $CharacterStateTextureRect/Sprite
onready var hp2 = $CharacterStateTextureRect/Sprite2
onready var hp3 = $CharacterStateTextureRect/Sprite3
onready var hp4 = $CharacterStateTextureRect/Sprite4

func _ready():
	container.set_visible(true)
	hp1.offset = Vector2(0,0)
	hp2.offset = Vector2(0,0)
	hp3.offset = Vector2(0,0)
	hp4.offset = Vector2(0,0)
	pass

func _physics_process(delta):
	pass
	
func health_down():
	match get_owner().get_owner().get_node("Player").hp:
		3:
			hp4.play_health_reduce_anim()
		2:
			hp3.play_health_reduce_anim()
		1:
			hp2.play_health_reduce_anim()
		0:
			hp1.play_health_reduce_anim()
			
	pass
