class_name ConstructionVisual extends Node2D

@export var backPath: NodePath
@onready var back := get_node(backPath) as ConstructionBackground
@export var edgePath: NodePath
@onready var edge := get_node(edgePath) as GradientPath2D

var zero_centrate := true
var glow := true
var glow_mult: float = 2.0

var config: ConstructionVisualConfiguration:
	set(value):
		config = value
		handle_config_update()

func _ready():
	handle_config_update()

func handle_config_update():
	if not is_node_ready(): return
	if not config:
		printerr("Construction visual have no config")
		return
	
	if zero_centrate:
		position = config.size * Vector2(-0.5, -0.5)
	
	var color = config.color * glow_mult if glow else config.color
	color = color.clamp()
	edge.fromColor = color
	edge.toColor = color
	edge.curve = config.adapted_edge
	edge.width = config.edge_width
	edge.queue_redraw()
	
	back.material = config.back_material
	back.size = maxf(config.size.x, config.size.y)
	back.queue_redraw()
