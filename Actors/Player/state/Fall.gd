extends State

var jump_force
var jump_anim_count

func _init(o).(o):
	pass

func enter():
	print_debug("Fall")
	owner.animation_tree.active = false
	
	jump_force = owner.jump_force
	jump_anim_count = jump_force * 0.8 * 2/7
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
		
	if owner.velocity.y <= -jump_force +jump_anim_count*5 and owner.velocity.y >= -jump_force +jump_anim_count*4 :
		owner.animation_sprite_sheet.set_frame(3)
	elif owner.velocity.y <= -jump_force +jump_anim_count*6 and owner.velocity.y >= -jump_force +jump_anim_count*5:
		owner.animation_sprite_sheet.set_frame(4)
	elif owner.velocity.y <= -jump_force +jump_anim_count*7 and owner.velocity.y >= -jump_force +jump_anim_count*6:
		owner.animation_sprite_sheet.set_frame(5)
	elif owner.velocity.y <= -jump_force +jump_anim_count*8 and owner.velocity.y >= -jump_force +jump_anim_count*7:
		owner.animation_sprite_sheet.set_frame(6)
	elif owner.velocity.y >= -jump_force +jump_anim_count*8:
		owner.animation_player.play("Fall_Anim")


func exit():
	owner.animation_player.stop(false)
	pass

func get_name():
	return "UnknownState"
