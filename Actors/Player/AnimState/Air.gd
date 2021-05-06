extends State
var Air_State_Machine: StateMachine

const AS_FallState = preload("res://Actors/Player/AnimState/Fall.gd") 
const AS_UpState = preload("res://Actors/Player/AnimState/Up.gd")
const AS_UptoFallState = preload("res://Actors/Player/AnimState/UptoFall.gd")


func _init(o).(o):
	Air_State_Machine = StateMachine.new(AS_UptoFallState.new(self))

func enter():
	pass
	
func execute():
	Air_State_Machine.update()
	
	if owner.is_on_floor():
		owner.anim_state_machine.change_state(owner.AS_GroundState.new(owner))	
	pass

func exit():
	pass

func get_name():
	return "Air"
