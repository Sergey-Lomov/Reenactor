class_name MemoryNode extends Node2D

var color: Color = Color.AQUA

# Called when the node enters the scene tree for the first time.
func _ready():
	var circle = get_node("Circle")
	circle.color = color
