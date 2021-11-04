extends Node2D

onready var input_module = get_node("PlayerInput")
onready var character = get_node("Character")

func _ready():
	pass

func _physics_process(delta):
	global_position = get_node("Character").global_position
