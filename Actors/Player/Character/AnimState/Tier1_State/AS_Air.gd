extends State
var Air_State_Machine: StateMachine

const AS_FallState = preload("res://Actors/Player/Character/AnimState/Tier2_State/AS_Fall.gd") 
const AS_UpState = preload("res://Actors/Player/Character/AnimState/Tier2_State/AS_Up.gd")
const AS_UptoFallState = preload("res://Actors/Player/Character/AnimState/Tier2_State/AS_UptoFall.gd")


func _init(o).(o):
	Air_State_Machine = StateMachine.new(AS_UptoFallState.new(self))

func enter():
	pass
	
func execute():
	Air_State_Machine.update()
	
	if owner.movement_module.is_on_object:
		owner.anim_state_machine.change_state(owner.AS_GroundState.new(owner))	
	pass

func exit():
	pass

func get_name():
	return "AS_Air"
