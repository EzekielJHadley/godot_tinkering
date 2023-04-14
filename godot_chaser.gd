extends CharacterBody2D

var speed = 500
var mouse_location: Vector2

func _physics_process(_delta):
	var mouse_pos = (mouse_location - position).normalized()#self.get_local_mouse_position().normalized()
	set_velocity(mouse_pos * speed)
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		mouse_location = event.position

