@tool
extends Area2D
class_name Generator

signal connect_gen		#send node_id
signal captured 		#send old_team, new_team
signal attack			#send node_id, ai_style

#0:neutral, 1:player, >=2 enemy!
@export var team: int = 0 : get = get_team, set = set_team
var team_color: Color
@export var initial_value: int = 10 : get = get_init_val, set = set_init_val
@export var max_connection_len: int = 250 : set = set_conn_len
var max_connection_len_sqr: int = int(pow(max_connection_len, 2))
var max_num_connections: int = 2

enum AI_TYPES {Player, Neutral, Aggresive, Custom}
@export var ai_style: AI_TYPES

#node_name, position, connector_id
@export var targets: Array[Dictionary] : set = set_targets, get = get_targets
var target_count: int = 0


@export var level = 1
var inc_sec: float = 1
var current_score: float : get = get_score, set = set_score
var i_frame: int = 30
var i_frame_count: int = 0
var damage_queue: Array = []

var level_base = 10
var level_scale = 2.5

#maintain a list of nearby targets
#Mostly for the AI attack, governed by the game module itself
#	as it has a global view, also i current spawn the connectors from there
#	maintain so the AI knows who it can attack
#	generated by global view
#list of dictionaries (maybe sort by distance? or leave that to attack function
#dictionary will include
#	generator_node_id: the id for the generators within range
#	connector_id: the id for the connector
#	direction: to ally, from ally, to enemy (don't need from enemy?)
#		this is to prevent going back and forth from two allies

func _ready():
	print("I am: %s(%s)" % [self.name, self.get_instance_id()])
	print(position)
	print(ai_style)
	print(targets)
	self.current_score = initial_value
	get_tree().debug_collisions_hint = true
	if team >= 2: #is an enemy
		$attack_timer.start()

#main loop
func _process(delta):
	if not Engine.is_editor_hint():
		#if not a neutral generator increment
		if self.team > 0:
			self.current_score += inc_sec * delta
			
#			if self.current_score >= level_scale * level_base * level:
#				level_up()
			
		#take damage
		for attacker in damage_queue:
			take_dmg(attacker["team"], attacker["dmg"])
		#clear the dmg queue
		damage_queue.clear()
		i_frame_count = max(i_frame_count-1, 0)

#func _get_property_list():
#	var properties = []
#	# Same as "export var my_property: int"
#	properties.append({
#		name = "targets",
#		type = TYPE_ARRAY
#	})
#	return properties

#############################################################################
#
#Generator properties
#
#############################################################################

#increase the level of this generator
#TODO: make this do something more
func level_up():
	level += 1
	inc_sec *= 1.5
	max_num_connections += 1

#addes to the list of targets that this generator is attacking
func attach_target(target_gen, obj_id):
	#first find the target generator
	for targ in targets:
		if targ["node_name"] == target_gen and targ["connector_id"] == 0:
			#this marks what target is connected and with what connector
			targ["connector_id"] = obj_id
			target_count += 1
			return true
	#if the connector is already defined or the target is not accesible 
	return false

#if the player removes a connection remove from list of targets
func detach_target(conn_id):
	#find the target generator
	for targ in targets:
		if targ["connector_id"] == conn_id:
			#remove the connector
			targ["connector_id"] = 0
			target_count -= 1
			

#run this for every frame for an attack value
func attack_node(delta):
	#having more connections means you deal less dmg
	var ret: float = max(log(self.current_score), inc_sec)/(target_count + 1)
	ret = ret * delta
	self.current_score -= ret
	return ret

#this is the damange recieved every frame
func defend_node(team_source, attk):
	damage_queue.append({"team":team_source, "dmg":attk})
	
func take_dmg(attk_team, dmg):
	#deal dmg or transfer hp
	if attk_team == self.team:
		self.current_score += dmg
	elif i_frame_count == 0: #invinsible frames
		self.current_score -= dmg
	#check if the generator has been won
	if current_score <= 0:
		self.current_score = 0.1
		self.team = attk_team
		target_count = 0
		for targ in targets:
			#remove all connections from this generator
			if targ["connector_id"] != 0:
				instance_from_id(targ["connector_id"]).queue_free()
				targ["connector_id"] = 0
		#you changed teams, now set the invisibility frame
		if i_frame_count == 0:
			i_frame_count = i_frame

#############################################################################
#
#signal triggered events
#
#############################################################################

func _on_ColorRect_gui_input(event):
	#when a player generator is clicked
	if event is InputEventMouseButton and event.pressed and team == 1:
		#either way handle the click
		get_viewport().set_input_as_handled()
		#only allow so many connections
		if target_count < max_num_connections:
#			print("the event i'm looking for")
#			print(event.as_text())
			emit_signal("connect_gen", get_instance_id())

func _on_attack_node_timeout():
	emit_signal("attack", get_instance_id(), ai_style)

#############################################################################
#
#Setters and getters!
#
#############################################################################
func set_team(new_team):
	emit_signal("captured", get_instance_id(), team, new_team)
	team = new_team
	input_pickable = true
	match new_team:
		0:
			team_color = Color.GRAY
			input_pickable = false
		1:
			print("Change to player")
			team_color = Color.BLUE
			$attack_timer.stop()
		2:
			team_color = Color.RED
			$attack_timer.start()
		_:
			team_color = Color.MAGENTA
			$attack_timer.start()
			
	$ColorRect.color = team_color

func get_team():
	return team

var rng = RandomNumberGenerator.new()
func get_random_target():
	var random_index = rng.randi_range(0, targets.size()-1)#inclusive
	return targets[random_index]

func set_init_val(value):
	initial_value = value
	self.current_score = initial_value

func get_init_val():
	return initial_value
	
func set_score(score):
	current_score = score
	$Label.text = "{score}".format({"score":int(current_score)})

func get_score():
	return current_score


func clear_targets():
	targets.clear()

func add_targets(target_gen: Generator):
	#node_name, position, connector_id
	var target = {"node_name":target_gen.name, "position":target_gen.get_global_position(), "connector_id":0}
	self.targets.append(target)
	
func set_targets(targs):
	targets = targs

func get_targets():
	return targets
	
func set_conn_len(distance):
	max_connection_len = distance
	max_connection_len_sqr = int(pow(distance, 2))
