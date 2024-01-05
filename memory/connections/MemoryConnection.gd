@tool
class_name MemoryConnection extends Node2D

var from: WeakRef
var to: WeakRef
var control1 = Vector2(0, 0)
var control2 = Vector2(0, 0)
var width: float = 5

func _ready():
	var path = get_node("Path")
	
	if from == null or to == null:
		return
	
	if from.get_ref() == null or to.get_ref() == null:
		return
	
	var from_ref = from.get_ref()
	var to_ref = to.get_ref()
	
	path.fromColor = from_ref.color
	path.toColor = to_ref.color
	
	var curve = Curve2D.new()
	curve.add_point(from_ref.position, Vector2(0, 0), control1)
	curve.add_point(to_ref.position, control2)
	path.curve = curve

	path.width = width
