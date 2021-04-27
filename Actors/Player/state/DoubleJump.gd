extends State

var jump_force
var double_anim_count


func _init(o).(o):
	pass

func enter():
	print_debug("DoubleJump")
	owner.animation_tree.active = false
	
	jump_force = owner.jump_force
	double_anim_count = jump_force * 0.8 * 2/7 *0.7
	pass
	
func execute():
	owner.move()
	
	if owner.is_on_floor() and owner.velocity.x == 0:
		owner.state_machine.change_state(owner.IdleState.new(owner))
	elif owner.is_on_floor()  and owner.velocity.x != 0:
		owner.state_machine.change_state(owner.RunState.new(owner))
	
	owner.animation_player.stop(false)	
	if owner.velocity.y <= -jump_force +double_anim_count*2 and owner.velocity.y >= -jump_force +double_anim_count:
		owner.animation_sprite_sheet.set_frame(37)
	elif owner.velocity.y <= -jump_force +double_anim_count*3 and owner.velocity.y >= -jump_force +double_anim_count*2:
		owner.animation_sprite_sheet.set_frame(38)
	elif owner.velocity.y <= -jump_force +double_anim_count*4 and owner.velocity.y >= -jump_force +double_anim_count*3:
		owner.animation_sprite_sheet.set_frame(39)
	elif owner.velocity.y <= -jump_force +double_anim_count*5 and owner.velocity.y >= -jump_force +double_anim_count*4 :
		owner.animation_sprite_sheet.set_frame(40)
	elif owner.velocity.y <= -jump_force +double_anim_count*6 and owner.velocity.y >= -jump_force +double_anim_count*5:
		owner.animation_sprite_sheet.set_frame(41)
	elif owner.velocity.y <= -jump_force +double_anim_count*7 and owner.velocity.y >= -jump_force +double_anim_count*6:
		owner.animation_sprite_sheet.set_frame(42)
	elif owner.velocity.y <= -jump_force +double_anim_count*8 and owner.velocity.y >= -jump_force +double_anim_count*7:
		owner.animation_sprite_sheet.set_frame(43)
	elif owner.velocity.y >= -jump_force +double_anim_count*8:
		owner.state_machine.change_state(owner.FallState.new(owner))
		
		
func exit():
	pass

func get_name():
	return "DoubleJump"
