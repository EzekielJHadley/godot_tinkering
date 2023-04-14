extends Node2D


var click_line = preload("res://clickable_line.tscn")
var teams: Dictionary = {}
var gen_positions = []

#var test_line = preload("res://test_line.tscn")
#var tester

# Called when the node enters the scene tree for the first time.
func _ready():
	#set up the game
#	get_tree().paused = true
#	PhysicsServer2D.set_active(true)
	#wait for everything to be loaded
	for gens in get_tree().get_nodes_in_group("gens"):
		print(gens)
		gens.connect("connect_gen",Callable(self,"spawn_connect"))
		gens.connect("captured",Callable(self,"update_teams"))
		gens.connect("attack",Callable(self,"attack_generator"))
		#force an update of the teams to initially populate it
		populate_teams(gens.get_instance_id(), gens.team)
		gen_positions.append({"gen_id":gens.get_instance_id(), "position":gens.get_position()})
		
#	tester = test_line.instantiate()
#	tester.set_points(Vector2(345, 244), Vector2(585, 272))
#	add_child(tester)
#	await get_tree().idle_frame
#	tester.call_deferred("check_overlap")
#	tester.check_overlap()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#to be run at scene start to populate who is on what team
func populate_teams(node_id, team_num):
	var team_num_key = str(team_num)

	if teams.has(team_num_key) and typeof(teams[team_num_key]) == TYPE_ARRAY:
		teams[team_num_key].append(node_id)
	else:
		teams[team_num_key] = [node_id]

#i assume nothing about the values in the teams dictionary
#so if that team is not a key it can be added
func update_teams(node_id, old_team, new_team):
	var old_team_key = str(old_team)
	var new_team_key = str(new_team)
	if teams.has(old_team_key) and typeof(teams[old_team_key]) == TYPE_ARRAY:
		teams[old_team_key].erase(node_id)
	
	if teams.has(new_team_key) and typeof(teams[new_team_key]) == TYPE_ARRAY:
		teams[new_team_key].append(node_id)
	else:
		teams[new_team_key] = [node_id]
	
	#check if you lose
	if not teams.has("1") or teams["1"].size() == 0:
		print("YOU LOSE!")
	
	#check if the other lists are empty
	var win:bool = true
	for team_key in teams:
		if team_key == "1":
			continue
		elif teams[team_key].size() != 0:
			win = false
			
	if win:
		print("YOU WIN!")
		$HUD.you_win()
	else:
		print("keep playing")
		
	print(teams)


#spawn a connector to be connected between two generators
#triggered by clicking on a generator you own
var connector = preload("res://connector.tscn")
var num_connectors = 0
func spawn_connect(obj, target_obj:Vector2 = Vector2.ZERO):
	var parent_obj: Generator = instance_from_id(obj)
	var connection: Connector = connector.instantiate()
	connection.set_name("Connector#" + str(num_connectors))
	num_connectors += 1
	get_child(0).add_sibling(connection)#make sure it is under all other children
	connection.at_start(parent_obj)
	
	if target_obj != Vector2.ZERO:
		connection.set_endpoint(target_obj)
		
#	print("---------------------------------------------------")
#	for gens in get_tree().get_nodes_in_group("gens"):
#		print("tree nodes in:")
#		print(gens)
#		for node in gens.get_children():
#			print("\t" + str(node))
#			if node is Connector:
#				for sub_node in node.get_children():
#					print("\t\t" + str(sub_node))
#		print("")
#	print("---------------------------------------------------")

#trigger an attack from each enemy generator
func attack_generator(obj_id, _attack_style):
	var attacking_obj = instance_from_id(obj_id)
	
	var target_gen = attacking_obj.get_random_target()
	
	if target_gen["connector_id"] == 0:
		spawn_connect(obj_id, target_gen["position"])
	
