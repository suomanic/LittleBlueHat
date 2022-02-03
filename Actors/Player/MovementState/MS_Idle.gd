extends State

func _init(o).(o):
	pass

func enter():
	pass
	
func execute():
	owner.movement_module.move()
	owner.movement_module.jump()
	owner.movement_module.apply_gravity(owner.get_physics_process_delta_time())
	owner.collision_module.facing()
	
	if owner.velocity.x !=0 and !owner.is_on_wall():
		owner.movement_state_machine.change_state(owner.MS_RunState.new(owner)) 
		
	elif (owner.movement_module._coyote_counter > 0 and owner.movement_module._jump_buffer_counter > 0)|| owner.velocity.y < 0:
		owner.jump_land_audio_player.stream = load("res://Assets/Audio/jump.wav")
		owner.jump_land_audio_player.play()
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
	elif owner.velocity.y < 0 and owner.collision_module.is_bounced:
		owner.movement_state_machine.change_state(owner.MS_UpState.new(owner))
		
	if owner.input_module.is_crouch_pressed and owner.movement_module.is_on_object:
		owner.movement_state_machine.change_state(owner.MS_CrouchState.new(owner))
	
func exit():
	pass

static func get_name():
	return "MS_Idle"
