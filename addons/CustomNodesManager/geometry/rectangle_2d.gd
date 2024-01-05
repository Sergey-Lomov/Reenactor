@tool
extends Node2D

@export var center: Vector2 = Vector2(0, 0):
	set(value):
		center = value
		notify_property_list_changed()
		
@export var size: Vector2 = Vector2(10, 10):
	set(value):
		size = value
		notify_property_list_changed()

@export var color: Color = Color.WHITE:
	set(value):
		color = value
		notify_property_list_changed()

# Called when the node enters the scene tree for the first time.
func _draw():
	draw_rect(Rect2(center - size * 0.5, size), color)
