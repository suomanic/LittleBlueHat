extends Object

class_name State

var owner = null

func _init(o):
	owner = o

func enter():
	pass

func execute():
	pass
	
func exit():
	pass

static func get_name():
	return "UnknowState"
