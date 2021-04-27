extends State

var jump_force
var jump_anim_count

func _init(o).(o):
	pass

func enter():
	print_debug("Up")
	owner.animation_tree.active = false
	jump_force = owner.jump_force
	jump_anim_count = jump_force * 0.8 * 2/7
	pass
	
func execute():
	owner.move()
	owner.jump()
	
	if owner.velocity.y > 0:
		owner.state_machine.change_state(owner.FallState.new(owner))
		
	if Input.is_action_just_pressed("jump"):
		owner.state_machine.change_state(owner.DoubleJumpState.new(owner))
	
	owner.animation_player.stop(false)
	if owner.velocity.y <= -jump_force +jump_anim_count:
		owner.animation_player.play("Up_Anim")
	else:
		owner.animation_player.stop(false)
		if owner.velocity.y <= -jump_force +jump_anim_count*2 and owner.velocity.y >= -jump_force +jump_anim_count:
			owner.animation_sprite_sheet.set_frame(0)
		elif owner.velocity.y <= -jump_force +jump_anim_count*3 and owner.velocity.y >= -jump_force +jump_anim_count*2:
			owner.animation_sprite_sheet.set_frame(1)
		elif owner.velocity.y <= -jump_force +jump_anim_count*4 and owner.velocity.y >= -jump_force +jump_anim_count*3:
			owner.animation_sprite_sheet.set_frame(2)
		elif owner.velocity.y <= -jump_force +jump_anim_count*5 and owner.velocity.y >= -jump_force +jump_anim_count*4 :
			owner.animation_sprite_sheet.set_frame(3)
	pass

func exit():
	owner.animation_tree.active = true
	pass

func get_name():
	return "Up"
