extends Node

#Points array routine
func points_wrapp_rect(points: Array[Vector2]) -> Rect2:
	var max_x = points.map(func(p): return p.x).max()
	var max_y = points.map(func(p): return p.y).max()
	var min_x = points.map(func(p): return p.x).min()
	var min_y = points.map(func(p): return p.y).min()
	return Rect2(min_x, min_y, max_x - min_x, max_y - min_y)

func points_has_approx(points: Array[Vector2], value: Vector2) -> bool:
	var filter = func(p): return (p as Vector2).is_equal_approx(value)
	return not points.filter(filter).is_empty()

func translated_points(points: Array[Vector2], delta: Vector2) -> Array[Vector2]:
	var new_points: Array[Vector2] = []
	new_points.assign(points.map(func(p): return p + delta))
	return new_points

func rotated_points(points: Array[Vector2], angle: float) -> Array[Vector2]:
	var new_points: Array[Vector2] = []
	new_points.assign(points.map(func(p): return p.rotated(angle)))
	return new_points
	
func scaled_points(points: Array[Vector2], x_scale: float, y_scale: float) -> Array[Vector2]:
	var new_points: Array[Vector2] = []
	new_points.assign(points.map(func(p): return p * Vector2(x_scale, y_scale)))
	return new_points

#Curve routine
func translated_curve(curve: Curve2D, delta: Vector2) -> Curve2D:
	var new_curve = Curve2D.new()
	for index in curve.point_count:
		var point = curve.get_point_position(index) + delta
		new_curve.add_point(point, curve.get_point_in(index), curve.get_point_out(index))
	return new_curve

func rotated_curve(curve: Curve2D, angle: float) -> Curve2D:
	var new_curve = Curve2D.new()
	for index in curve.point_count:
		var point = curve.get_point_position(index).rotated(angle)
		var point_in = curve.get_point_in(index).rotated(angle)
		var point_out = curve.get_point_out(index).rotated(angle)
		new_curve.add_point(point, point_in, point_out)
	return new_curve
	
func scaled_curve(curve: Curve2D, x_scale: float, y_scale: float) -> Curve2D:
	var new_curve = Curve2D.new()
	var scale = Vector2(x_scale, y_scale)
	for index in curve.point_count:
		var point = curve.get_point_position(index) * scale
		var point_in = curve.get_point_in(index) * scale
		var point_out = curve.get_point_out(index) * scale
		new_curve.add_point(point, point_in, point_out)
	return new_curve
	
func reversed_curve(curve: Curve2D) -> Curve2D:
	var new_curve = Curve2D.new()
	for iterator in curve.point_count:
		var index = curve.point_count - iterator - 1
		new_curve.add_point(curve.get_point_position(index), curve.get_point_out(index), curve.get_point_in(index))
	return new_curve
