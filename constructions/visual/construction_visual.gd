class_name ConstructionVisual extends Node2D

@export var backPath: NodePath
@onready var back := get_node(backPath) as ConstructionBackground

var back_material: Material:
	set(value): back.material
	get: return back.material

var contruction_size: Vector2 = Vector2(165, 165):
	set(value):
		contruction_size = value
		if is_node_ready():
			back.size = value
			back.queue_redraw()

func _ready():
	back.size = contruction_size
	back.queue_redraw()	
