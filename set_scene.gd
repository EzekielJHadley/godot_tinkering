@tool
extends EditorScript

var test_line = preload("res://test_line.tscn")
var tester: Test_Line

func _run():
	var generators = get_scene().get_tree().get_nodes_in_group("gens")
	for gens in generators:
		print(gens)
		var gen_range_sqr = gens.max_connection_len_sqr
#		print(gen_range_sqr)
		gens.clear_targets()
		for targets in generators:
			print(targets)
			if gens != targets:
				var target_pos = targets.get_global_position()
				var distance_sqr = gens.get_global_position().distance_squared_to(target_pos)
#				var test_dist = "%s >= %s: %s"% [gen_range_sqr, distance_sqr, gen_range_sqr >= distance_sqr]
#				print(test_dist)
				if gen_range_sqr >= distance_sqr:
					create_test_line(gens, targets)
					print("connection found")
#					gens.targets.append(Target.new(targets.get_instance_id(), target_pos))
		
		


func create_test_line(gen, targ):
	var gen_pos = gen.get_global_position()
	var targ_pos = targ.get_global_position()
	tester = test_line.instantiate()
	tester.source_gen_name = gen.name
	tester.source_gen_id = gen.get_instance_id()
	tester.target_gen_name = targ.name
	tester.target_gen_id = targ.get_instance_id()
	tester.set_points(gen_pos, targ_pos)
	get_scene().add_child(tester)
	#inorder for the node to persist it's owner needs to be this scene
	tester.set_owner(get_scene())
#	await get_scene().get_tree().create_timer(1).timeout
#	print("before await")
#	await get_scene().get_tree().process_frame
#	print("after await")
##	var collisions = tester.call_deferred("check_overlap")
#	var collisions = tester.check_overlap()
#	tester.queue_free()
	
#	return collisions
