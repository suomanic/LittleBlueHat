extends State

var jump_force
var double_anim_count

func _init(o).(o):
	pass

func enter():
	owner.animation_player.stop(false)
	print_debug("DoubleJump")
	owner.animation_player.play("DoubleJump_Anim")
	
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	
	if owner.is_on_floor() and owner.velocity.x == 0:
		owner.state_machine.change_state(owner.MS_IdleState.new(owner))
	elif owner.is_on_floor() and owner.velocity.x != 0:
		owner.state_machine.change_state(owner.MS_RunState.new(owner))
	
	if owner.velocity.y >= owner.movement_module.jump_force:
		owner.state_machine.change_state(owner.MS_FallState.new(owner))
		
		
func exit():
	pass

func get_name():
	return "DoubleJump"
