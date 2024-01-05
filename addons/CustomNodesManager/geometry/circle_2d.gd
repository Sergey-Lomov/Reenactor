@tool
class_name Circle2D extends Node2D

@export var center: Vector2 = Vector2(0, 0):
	set(value):
		center = value
		notify_property_list_changed()
		
@export var radius: int:
	set(value):
		radius = value
		notify_property_list_changed()

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		notify_property_list_changed()

# Called when the node enters the scene tree for the first time.
func _draw():
	draw_circle(center, radius, color)
