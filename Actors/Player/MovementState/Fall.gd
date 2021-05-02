extends State

var jump_force
var jump_anim_count

func _init(o).(o):
	pass

func enter():
	print_debug("Fall")
	jump_force = owner.jump_force
	jump_anim_count = jump_force * 0.8 * 2/7
	
	if owner.velocity.y >= jump_force:
		owner.animation_player.play("Fall_Anim")
	else:
		owner.animation_player.play("toFall_Anim")
	pass
	
func execute():
	owner.move()
	owner.jump()
	
	if owner.is_on_floor():
		owner.state_machine.change_state(owner.IdleState.new(owner))
	elif owner.velocity.y < 0 :
		owner.state_machine.change_state(owner.UpState.new(owner))
		
	if Input.is_action_just_pressed("jump"):
		owner.state_machine.change_state(owner.DoubleJumpState.new(owner))
		
	


func exit():
	pass

func get_name():
	return "Fall"
