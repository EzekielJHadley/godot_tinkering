@tool
extends EditorScript

func _run():
	print("before await")
	#await get_scene().get_tree().create_timer(1).timeout
	#awaits do not work in Tool EdictorScripts, and may never
#	await get_scene().get_tree().process_frame
	print("after await")
	print(213545 >= 62500)
