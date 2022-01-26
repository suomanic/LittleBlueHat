extends State

func _init(o).(o):
	pass

func enter():
	owner.can_attack = true
	owner.can_change_weapon = true
	pass
	
func execute():
	if owner.owner != null:
		owner.follow_player()
	pass

func exit():
	owner.can_attack = false
	owner.can_change_weapon = false
	pass

static func get_name():
	return "ready"
