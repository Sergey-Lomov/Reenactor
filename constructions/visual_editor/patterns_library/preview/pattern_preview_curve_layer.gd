class_name CVE_PatternPreviewCurveLayer extends Control

var curve: Curve2D:
	set(value):
		curve = value
		update_adapted_curve()

var coords_translate: Vector2:
	set(value):
		coords_translate = value
		update_adapted_curve()

var coords_scale: float:
	set(value):
		coords_scale = value
		update_adapted_curve()
		
var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()

var width: float = 2:
	set(value):
		width = value
		queue_redraw()

var adapted_curve: Curve2D

func _draw():
	if adapted_curve != null:
		draw_polyline(adapted_curve.get_baked_points(), color, width, true)

func update_adapted_curve():
	if curve == null or coords_scale == null:
		adapted_curve = null
		queue_redraw()	
		return
	
	adapted_curve = Curve2D.new()
	for index in curve.point_count:
		var point = (curve.get_point_position(index) + coords_translate) * coords_scale + get_parent_area_size() / 2
		var point_in = curve.get_point_in(index) * coords_scale
		var point_out = curve.get_point_out(index) * coords_scale
		adapted_curve.add_point(point, point_in, point_out)
	queue_redraw()	
