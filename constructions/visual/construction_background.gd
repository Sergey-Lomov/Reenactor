@tool
class_name ConstructionBackground extends Node2D

var size: float:
	set(value):
		size = value
		if is_node_ready():
			handle_size_update()

func _ready():
	handle_size_update()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.WHITE)
	
func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

func handle_size_update():
	if not size: return
	material.set_shader_parameter("texture_size", size)
