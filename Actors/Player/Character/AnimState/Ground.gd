extends State

var Ground_State_Machine :StateMachine

const AS_IdleState = preload("res://Actors/Player/Character/AnimState/Idle.gd")
const AS_RunState = preload("res://Actors/Player/Character/AnimState/Run.gd")
const AS_CrouchState = preload("res://Actors/Player/Character/AnimState/Crouch.gd")

func _init(o).(o):
	pass

func enter():
	Ground_State_Machine = StateMachine.new(AS_IdleState.new(self))
	pass
	
func execute():
	Ground_State_Machine.update()
	
	if !owner.is_on_floor() and abs(owner.velocity.y) > 20:
		owner.anim_state_machine.change_state(owner.AS_AirState.new(owner))	
	pass

func exit():
	pass

func get_name():
	return "Ground"
