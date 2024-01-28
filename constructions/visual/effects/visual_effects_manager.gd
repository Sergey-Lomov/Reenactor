class_name VE_Manager extends Node

@export var layerPath: NodePath
@onready var layer := get_node(layerPath) as CanvasLayer

func add_trail() -> VE_Trail:
	if not layer: return null
	var trail = VE_PlasmaTrail.new()
	layer.add_child(trail)
	return trail
