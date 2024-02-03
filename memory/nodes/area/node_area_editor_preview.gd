class_name NAE_Preview extends Control

var sectors: int = 1
var show_controls: bool = true:
	set(value):
		show_controls = value
		queue_redraw()

var show_marking: bool = true:
	set(value):
		show_marking = value
		queue_redraw()

var curves: Array[Curve2D] = []:
	set(value):
		curves = value
		queue_redraw()

var point_radius: float = 3
var control_point_radius: float = 3

var back_color := Color(0.1, 0.1, 0.1)
var marking_color := Color(0.15, 0.15, 0.15)
var curve_color := Color.CORNFLOWER_BLUE
var control_points_color := Color.WEB_GREEN
var control_lines_color := Color.DARK_GREEN
var points_color := Color.ANTIQUE_WHITE


func _draw():
	draw_back()
	if show_marking: draw_marking()
	draw_curves()

func draw_back():
	draw_circle(size * 0.5, size.x / 2, back_color)

func draw_marking():
	if sectors <= 1: return
	var angle_step = PI * 2 / sectors
	for i in sectors:
		var angle = i * angle_step
		var to = Vector2(cos(angle), sin(angle)) * size.x / 2.0
		draw_line(size * 0.5, size * 0.5 + to, marking_color, -1, true)

func draw_curves():
	if curves.is_empty(): return
	for curve in curves:
		if curve.point_count >= 2:
			draw_polyline(curve.get_baked_points(), curve_color, 2, true)	
	if show_controls: 
		draw_controls(curves.front())
	
func draw_controls(curve: Curve2D):
	for index in curve.point_count:
		var pos = curve.get_point_position(index)
		var in_pos = curve.get_point_in(index)
		var out_pos = curve.get_point_out(index)
		
		draw_circle(pos, point_radius, points_color)
		
		if not in_pos.is_equal_approx(Vector2.ZERO):
			draw_line(pos, pos + in_pos, control_lines_color, -1.0, true)
			draw_circle(pos + in_pos, control_point_radius, control_points_color)
			
		if not out_pos.is_equal_approx(Vector2.ZERO):
			draw_line(pos, pos + out_pos, control_lines_color, -1.0, true)
			draw_circle(pos + out_pos, control_point_radius, control_points_color)