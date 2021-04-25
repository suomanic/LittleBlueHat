extends "res://StateMachine.gd"

func _ready():
	add_state("idle")
	add_state("singlejump_up")
	add_state("jump_uptodown")
	add_state("fall")
	add_state("crouch")
	add_state("crouch_move")
	add_state("doublejump")
	call_deferred("set_state",states.idle)

func _state_logic(delta):
	pass
	 
func _get_transition(delta):
	return null
		
func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state , new_state):
	pass
