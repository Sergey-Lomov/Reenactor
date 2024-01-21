@tool
extends Node2D

func _draw():
	var patterns = CVE_PatternsManager.get_patterns("simple_rounded")
	var curve = Curve2D.new()
	curve.add_point(Vector2(50, 50))
	for pattern in patterns:
		pattern.apply(curve, 0, 25)
	
	if curve.point_count >= 2:
		draw_polyline(curve.get_baked_points(), Color(0.7, 0.0, 0.7), 1, true)

func _process(delta):
	if Engine.is_editor_hint():
		queue_redraw()
