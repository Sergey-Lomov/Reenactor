@tool
class_name Circle2D extends ShaderRenderable
	
@export var radius: int:
	set(value):
		radius = value
		update_renderer_size()
		set_renderer_parameter("radius", radius)

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		set_renderer_parameter("main_color", color)
		
@export var border_width: float = 0:
	set(value):
		border_width = value
		update_renderer_size()
		set_renderer_parameter("border_width", border_width)

@export var border_color: Color = Color.WHITE:
	set(value):
		border_color = value
		set_renderer_parameter("border_color", border_color)
		
const gap: float = 2 #Additional gap for cover edge smoothing

func get_shader() -> Shader:
	return preload("res://addons/CustomNodesManager/geometry/circle_2d.gdshader")

func get_size() -> Vector2:
	var size = (radius + gap) * 2 + border_width #Border width not multiplied by 2, because half of width overlap circle (moves inside radius)
	return Vector2(size, size)
