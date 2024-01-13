@tool
class_name SquareGrid extends Control

@export var step: int = 10:								#Grid step size
	set(value):
		step = value
		queue_redraw()
		
@export var color: Color = Color(0.15, 0.15, 0.15):		#Grid color
	set(value):
		color = value
		queue_redraw()
		
@export var translate: Vector2 = Vector2.ZERO:			#Grid center displacement related to view center
	set(value):
		translate = value
		queue_redraw()
		
func _draw():
	var center = size / 2 + translate
	var h_left_count = floor(center.x / step)
	var v_top_count = floor(center.y / step)
	var left = center.x - h_left_count * step
	var top = center.y - v_top_count * step
	
	for index in floor(size.x / step + 1):
		var x = left + index * step
		if x <= size.x:
			draw_line(Vector2(x, 0), Vector2(x, size.y), color, true)
	
	for index in floor(size.y / step + 1):
		var y = top + index * step
		if y <= size.y:
			draw_line(Vector2(0, y), Vector2(size.x, y), color, true)
	
