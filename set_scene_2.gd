@tool
extends EditorScript


func _run():
	var testers = get_scene().get_tree().get_nodes_in_group("test_line")
	for test in testers:
		var collisions = test.check_overlap()
		if collisions:
			var result = "%s connects to %s"% [ test.source_gen_name, test.target_gen_name]
			print(result)
			var source_gen = instance_from_id(test.source_gen_id)
			source_gen.add_targets(instance_from_id(test.target_gen_id))
	
	while(testers.size() > 0):
		var test = testers.pop_front()
		test.free()

	var generators = get_scene().get_tree().get_nodes_in_group("gens")
	for gens in generators:
		print(gens.targets)
