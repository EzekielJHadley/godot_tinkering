extends CanvasLayer


func _ready():
	$menu_container.visible = false
	$menu_container/Next_level.visible = false
	

func you_win():
	_on_menu_pressed()
	$menu_container/Next_level.visible = true

func _on_menu_pressed():
	get_tree().paused = not get_tree().paused
	$menu_container.visible = not $menu_container.visible

func _input(event):
	if event.is_action_pressed("menu"):
		_on_menu_pressed()


func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://level_select.tscn")
