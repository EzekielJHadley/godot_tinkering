extends Area2D
class_name Connector

var gen_source: Generator
var gen_target: Generator = null

var max_length: int = 100

# Called when the node enters the scene tree for the first time.
func at_start(parent_node):
	gen_source = parent_node
	var start_points = [gen_source.get_position(), gen_source.get_position()]
	$Line2D.set_points(PackedVector2Array(start_points))
	$Line2D.default_color = gen_source.team_color
	
	$follower.set_position(gen_source.get_position())
	
	max_length = gen_source.max_connection_len
	#strange memory leak causes this to be where the last one ended
	#set_endpoint(gen_source.get_position())
	
	get_tree().debug_collisions_hint = true
#	print("start position")
#	print(str(self))
#	print(get_global_position())
	
	

func _process(delta):
	#controll the line when it isn't yet connected to something
	if gen_target == null and gen_source.team == 1:
		#var cursor_loc = get_viewport().get_mouse_position()
		var cursor_loc = $follower.get_global_position()
		set_endpoint(cursor_loc)
	elif gen_target == null:
		pass #hack for the breif frame the enemy attacks but isn't connected 
	elif gen_target.team != gen_source.team: #when connected to different nodes attack
		gen_target.defend_node(gen_source.team, gen_source.attack_node(delta))
	elif gen_target.team == gen_source.team: 
		#just keep transfering over value
		gen_target.defend_node(gen_source.team, gen_source.attack_node(delta))
#		if gen_target.current_score < gen_source.current_score: #when connected to nodes of the same team transfer from higher to lower
#			gen_target.defend(gen_source.team, -gen_source.attack())
#		else:
#			gen_source.defend(gen_target.team, -gen_target.attack())


func set_endpoint(loc:Vector2, final:bool=false):
	var rel_end_point: Vector2
	var line_length: float
	var end_point: Vector2
	var mid_point:Vector2
	
	if not final:
		rel_end_point= loc - gen_source.get_position()
		line_length = min(rel_end_point.length(), max_length)
		end_point = gen_source.get_position() + rel_end_point.normalized()*line_length
		mid_point = gen_source.get_position() + rel_end_point.normalized()*line_length/2
	else:#if the center of the final is slightly more than the limit ignore
		rel_end_point = loc - gen_source.get_position()
		line_length =rel_end_point.length()
		end_point = gen_source.get_position() + rel_end_point.normalized()*line_length
		mid_point = gen_source.get_position() + rel_end_point.normalized()*line_length/2
	
	$Line2D.set_point_position(1,  end_point)

	#	$destination_collision/Label.set_position(loc)
	$destination_collision.position = mid_point
	#the rectagle is defined by a vector to the lower right corner
	$destination_collision.set_rotation(rel_end_point.angle())
	#becasue i'm rotating it, i need to use the length of line
	#to define the relative vector
	#var line_len = ($Line2D.get_point_position(1) - $Line2D.get_point_position(0)).length()
	var extend_val:Vector2 = Vector2(line_length, $Line2D.width)
	$destination_collision.shape.size = extend_val #set_extents(extend_val)

func _input(event):
	if gen_target == null and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		self.queue_free()

func _on_Connector_area_entered(area):
	if area != gen_source and area is Generator:
		gen_target = area
		#first check with gen source if it isn't already connected with target
		if not gen_source.attach_target(gen_target.name, self.get_instance_id()):
			#if it returns false, destroy this connection
			#the source is already connected to the target
			self.queue_free()
		
		set_endpoint(area.get_global_position(), true)
		#kill the mouse follower
		$follower.queue_free()
		#$destination_collision.set_deferred("disabled", true)
		#no need for it to collide with anythign anymore
		#set_collision_mask_value(0, false)
#		print("end position")
#		print(get_global_position())


func _on_Connector_input_event(_viewport, event, _shape_idx):
#	print("hey")
#	print(event)
	if event is InputEventMouseButton and event.pressed and not get_viewport().is_input_handled():
		get_viewport().set_input_as_handled()
		print("click?")
		gen_source.detach_target(self.get_instance_id())
		self.queue_free()



func _on_body_entered(body):
	#this is if it hits a barrier
	print("hit a body")
	if body.is_in_group("barrier"):
		self.queue_free()
