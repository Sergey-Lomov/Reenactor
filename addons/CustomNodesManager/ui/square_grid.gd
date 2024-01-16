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
	var parent_size = get_parent_area_size()
	var center = parent_size / 2 + translate * step
	var h_left_count = floor(center.x / step)
	var v_top_count = floor(center.y / step)
	var left = center.x - h_left_count * step
	var top = center.y - v_top_count * step
	
	var v_lines = floor(parent_size.y / step + 1)
	if v_lines > 0 and v_lines < INF:
		for index in v_lines:
			var x = left + index * step
			if x <= parent_size.x:
				draw_line(Vector2(x, 0), Vector2(x, parent_size.y), color, true)
	
	var h_lines = floor(parent_size.y / step + 1)
	if h_lines > 0 and h_lines < INF:
		for index in h_lines:
			var y = top + index * step
			if y <= parent_size.y:
				draw_line(Vector2(0, y), Vector2(size.x, y), color, true)
	
