extends State

var jf
var djf
var double_anim_count
var up_anim_count
var velocity_y 

func _init(o).(o):
	pass

func enter():
	print_debug("UptoFall")
	owner.owner.animation_player.stop(false)
	
	jf =  owner.owner.movement_module.jump_force
	djf = owner.owner.movement_module.double_jump_force
	up_anim_count = 2 * jf / 7 
	double_anim_count = 2 * djf / 7 
	
func execute():
	velocity_y = owner.owner.velocity.y
	
	if owner.owner.movement_module.jump_count == 2:
		if velocity_y > -djf && velocity_y < -djf + double_anim_count:
			owner.owner.animation_sprite_sheet.set_frame(37)
		elif velocity_y > -djf + double_anim_count && velocity_y < -djf + double_anim_count*2:
			owner.owner.animation_sprite_sheet.set_frame(38)
		elif velocity_y > -djf + double_anim_count*2 && velocity_y < -djf + double_anim_count*3:
			owner.owner.animation_sprite_sheet.set_frame(39)
		elif velocity_y > -djf + double_anim_count*3 && velocity_y < -djf + double_anim_count*4:
			owner.owner.animation_sprite_sheet.set_frame(40)
		elif velocity_y > -djf + double_anim_count*4 && velocity_y < -djf + double_anim_count*5:
			owner.owner.animation_sprite_sheet.set_frame(41)
		elif velocity_y > -djf + double_anim_count*5 && velocity_y < -djf + double_anim_count*6:
			owner.owner.animation_sprite_sheet.set_frame(42)
		elif velocity_y > -djf + double_anim_count*6 && velocity_y < -djf + double_anim_count*7:
			owner.owner.animation_sprite_sheet.set_frame(6)
		elif velocity_y > -djf + double_anim_count*7:
			owner.Air_State_Machine.change_state(owner.AS_FallState.new(owner))
	else:
		if velocity_y > -jf && velocity_y < -jf + up_anim_count:
			owner.owner.animation_sprite_sheet.set_frame(0)
		elif velocity_y > -jf + up_anim_count && velocity_y < -jf + up_anim_count*2:
			owner.owner.animation_sprite_sheet.set_frame(1)
		elif velocity_y > -jf + up_anim_count*2 && velocity_y < -jf + up_anim_count*3:
			owner.owner.animation_sprite_sheet.set_frame(2)
		elif velocity_y > -jf + up_anim_count*3 && velocity_y < -jf + up_anim_count*4:
			owner.owner.animation_sprite_sheet.set_frame(3)
		elif velocity_y > -jf + up_anim_count*4 && velocity_y < -jf + up_anim_count*5:
			owner.owner.animation_sprite_sheet.set_frame(4)
		elif velocity_y > -jf + up_anim_count*5 && velocity_y < -jf + up_anim_count*6:
			owner.owner.animation_sprite_sheet.set_frame(5)
		elif velocity_y > -jf + up_anim_count*6 && velocity_y < -jf + up_anim_count*7:
			owner.owner.animation_sprite_sheet.set_frame(6)
		elif velocity_y > - jf + up_anim_count*7:
			owner.Air_State_Machine.change_state(owner.AS_FallState.new(owner))
		
	if velocity_y < -jf:
		owner.Air_State_Machine.change_state(owner.AS_UpState.new(owner))
	
	pass

func exit():
	pass

func get_name():
	return ""
