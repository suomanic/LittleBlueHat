extends Area2D

var state_machine : StateMachine

onready var anim_player = $AnimationPlayer

const N_IdleState = preload("res://Actors/Enemy/Mashroom/State/N_Idle.gd")

func _ready():
	state_machine = StateMachine.new(N_IdleState.new(self))
