extends Resource
class_name Target


@export var node_name: StringName
@export var position: Vector2
var connector_id: int = 0 : set = set_connector


func _init(name: StringName, id: int, pos:Vector2):
	node_name = name
	position = pos

func set_connector(conn_id: int):
	connector_id = conn_id
	
func remove_connector():
	connector_id = 0

func _to_string():
	var println
	if connector_id != 0:
		println = "{Targetting %s at %s by way of %s}" % [node_name, position, connector_id]
	else:
		println = "{Targetting %s is at %s}" % [node_name, position]
	return println

#func is_type(type): 
#	return type == "Target" or super.is_type(type)
	
#func    get_type(): 
#	return "Target"
