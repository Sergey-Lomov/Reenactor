@tool
class_name ConstructionBackground extends Node2D

#@export var material_resource: Material:
	#set(value):
		#material_resource = value
		#if is_node_ready():
			#material = material_resource

var size: float:
	set(value):
		size = value
		if is_node_ready():
			handle_size_update()

#var curve: Curve2D:
	#set (value):
		#curve = value
		#if is_node_ready():
			#handle_curve_update()

func _ready():
	#handle_curve_update()
	handle_size_update()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, Vector2(size, size)), Color.WHITE)
	
func _process(_delta):
	if Engine.is_editor_hint():
		queue_redraw()

#func handle_curve_update():
	#pass
	#if curve:
		#var points = curve.get_baked_points()
		#material.set_shader_parameter("points_count", points.size())
		#
		#var act_points: Array[Vector2] = [] 
		#for point in points:
			#act_points.append(point / size)
		#material.set_shader_parameter("points", act_points)

func handle_size_update():
	if not size: return
	material.set_shader_parameter("texture_size", size)
