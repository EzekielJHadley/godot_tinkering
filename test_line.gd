@tool
extends Area2D
class_name Test_Line

signal overlap #emit if it is overlapping anything

@export var source_gen_name: StringName : set = set_source_name, get = get_source_name
var source_gen_id: int : set = set_source_id, get = get_source_id
@export var target_gen_name: StringName : set = set_target_name, get = get_target_name
var target_gen_id: int : set = set_target_id, get = get_target_id

func _ready():
	PhysicsServer2D.set_active(true)
#	connect("body_entered",Callable(self,"check_overlap"))

func set_points(start_pnt:Vector2, end_pnt:Vector2):
	var start_points = [start_pnt, end_pnt]
	$Line2D.set_points(PackedVector2Array(start_points))
	
	var rel_end_point: Vector2
	var line_length: float
	var end_point: Vector2
	var mid_point:Vector2
	
	rel_end_point= end_pnt - start_pnt 
	line_length = rel_end_point.length()
	end_point = start_pnt + rel_end_point.normalized()*line_length
	mid_point = start_pnt + rel_end_point.normalized()*line_length/2
	
	$CollisionShape2D.position = mid_point
	$CollisionShape2D.set_rotation(rel_end_point.angle())
	var extend_val:Vector2 = Vector2(line_length, $Line2D.width)
	$CollisionShape2D.shape.size = extend_val

#func _ready():
#	var overlaps = get_overlapping_bodies()
#	print("--------------------------------------------")
#	print("tester overlaps the following:")
#	print(overlaps)
#	print(get_overlapping_areas())
#	print("--------------------------------------------")
	
func set_source_name(gen: StringName):
	print("source gen")
	print(gen)
	source_gen_name = gen

func get_source_name() -> StringName:
	return source_gen_name
	
func set_source_id(gen_id: int):
	source_gen_id = gen_id
	
func get_source_id() -> int:
	return source_gen_id

func set_target_name(gen: StringName):
	print("target gen")
	print(gen)
	target_gen_name = gen

func get_target_name() -> StringName:
	return target_gen_name
	
func set_target_id(gen_id: int):
	target_gen_id = gen_id
	
func get_target_id() -> int:
	return target_gen_id

func check_overlap(body=null):
	var barriers = get_overlapping_bodies()
	var generators = get_overlapping_areas()
	print("--------------------------------------------")
	print("tester overlaps the following:")
	print(barriers)
	print(generators)
	print("--------------------------------------------")

	if barriers.size() > 0:
		return false
	elif generators.size() >= 2:
		return true
	else:
		return false
