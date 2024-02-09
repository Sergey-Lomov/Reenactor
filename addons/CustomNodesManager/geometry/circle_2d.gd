@tool
class_name Circle2D extends Node2D
	
@export var radius: int:
	set(value):
		radius = value
		if is_node_ready(): update_shader_parameters()
		notify_property_list_changed()

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		if is_node_ready(): update_shader_parameters()
		notify_property_list_changed()
		
@export var border_width: float = 0:
	set(value):
		border_width = value
		if is_node_ready(): update_shader_parameters()
		notify_property_list_changed()

@export var border_color: Color = Color.WHITE:
	set(value):
		border_color = value
		if is_node_ready(): update_shader_parameters()
		notify_property_list_changed()
		
const gap: Vector2 = Vector2(2, 2) #Additional gap for cover edge smoothing

var rect: Rect2:
	get:
		var size = (Vector2(radius + border_width, radius + border_width) + gap) * 2
		return Rect2(size * -0.5, size)

var shader = preload("res://addons/CustomNodesManager/geometry/circle_2d.gdshader")

func _draw():
	draw_rect(rect, Color.WHITE)

func _enter_tree():
	if not material:
		material = ShaderMaterial.new()
		material.shader = shader

func _ready():
	update_shader_parameters()
	
func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()

func update_shader_parameters():
	material.set_shader_parameter("texture_size", rect.size)
	material.set_shader_parameter("radius", radius)
	material.set_shader_parameter("main_color", color)
	material.set_shader_parameter("border_color", border_color)
	material.set_shader_parameter("border_width", border_width)
