class_name NAE_Preview extends Control

var sectors: int = 1
var radiuses: int = 1

var show_controls: bool = false:
	set(value):
		show_controls = value
		queue_redraw()

var show_marking: bool = false:
	set(value):
		show_marking = value
		queue_redraw()
		
var show_intersections: bool = false:
	set(value):
		show_intersections = value
		queue_redraw()
		
var show_curves: bool = true:
	set(value):
		show_curves = value
		queue_redraw()
		
var show_spaces: bool = false:
	set(value):
		show_spaces = value
		queue_redraw()

var curves: Array[Curve2D] = []:
	set(value):
		curves = value
		queue_redraw()
		
var intersections: Array[Vector2] = []:
	set(value):
		intersections = value
		queue_redraw()
		
var free_spaces: Array[MandalaManager.NodeFreeSpace] = []:
	set(value):
		free_spaces = value
		queue_redraw()
		
var point_radius: float = 3
var intersection_point_radius: float = 3
var control_point_radius: float = 3

var back_color := Color(0.1, 0.1, 0.1)
var marking_color := Color(0.175, 0.175, 0.175)
var marking_secondary_color := Color(0.125, 0.125, 0.125)
var intersections_color := Color.YELLOW
var curve_color := Color.CORNFLOWER_BLUE
var lead_spaces_color := Color.RED
var spaces_color := Color.ORANGE
var control_points_color := Color.WEB_GREEN
var control_lines_color := Color.DARK_GREEN
var points_color := Color.ANTIQUE_WHITE

var center: Vector2:
	get: return size * 0.5

func _draw():
	draw_back()
	if show_marking: draw_marking()
	if show_spaces: draw_free_spaces()
	if show_curves: draw_curves()
	if show_controls and not curves.is_empty(): draw_controls(curves.front())
	if show_intersections: draw_intersections()

func draw_back():
	draw_circle(center, size.x / 2, back_color)

func draw_marking():
	if sectors > 1:
		var angle_step = PI / sectors
		for i in sectors * 2:
			var angle = i * angle_step
			var to = Vector2(cos(angle), sin(angle)) * size.x / 2.0
			var color = marking_color if i % 2 == 0 else marking_secondary_color
			draw_line(center, center + to, color, -1, true)
	
	if radiuses > 1:
		var radius_step = size.x / 2 / radiuses
		for i in radiuses:
			var radius = (i + 0.5) * radius_step
			draw_arc(center, radius, 0, TAU, 120, marking_color, -1, false)

func draw_curves():
	if curves.is_empty(): return
	for curve in curves:
		if curve.point_count >= 2:
			draw_polyline(curve.get_baked_points(), curve_color, 2, true)	
	
func draw_free_spaces():
	for i in free_spaces.size():
		var is_lead = i < free_spaces.size() / float(sectors)
		var color = lead_spaces_color if is_lead else spaces_color
		#draw_arc(free_spaces[i].position, free_spaces[i].radius, 0, TAU, 60, color, 2, false)
		draw_circle(free_spaces[i].position, free_spaces[i].radius, color)
	
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

func draw_intersections():
	for point in intersections:
		draw_circle(point, intersection_point_radius, intersections_color)
