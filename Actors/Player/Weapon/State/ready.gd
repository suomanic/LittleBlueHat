extends State

func _init(o).(o):
	pass

func enter():
	owner.can_attack = true
	owner.can_change_weapon = true
	pass
	
func execute():
	if owner.owner.get_node("Character") != null:
		owner.follow_player()
	pass

func exit():
	owner.can_attack = false
	owner.can_change_weapon = false
	pass

func get_name():
	return "ready"
