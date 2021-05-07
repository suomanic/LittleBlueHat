extends Node2D

func _ready():
	pass

func _physics_process(delta):
	self.global_position = self.global_position.linear_interpolate(owner.input_module.mouse_global_position,0.1)
	
	
	if Input.is_action_just_pressed("attack"):
		$AnimationPlayer.play("attack")
	pass
