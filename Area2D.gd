extends StaticBody2D



func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed:
		print("clickable line is clickable")
