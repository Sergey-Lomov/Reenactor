@tool
extends Node

#Floats routine
func greater_or_equal_approx(v1: float ,v2: float) -> bool:
	return v1 > v2 or is_equal_approx(v1, v2)
	
func greater_approx(v1: float ,v2: float) -> bool:
	return v1 > v2 and not is_equal_approx(v1, v2)
	
func less_or_equal_approx(v1: float ,v2: float) -> bool:
	return v1 < v2 or is_equal_approx(v1, v2)
	
func less_approx(v1: float ,v2: float) -> bool:
	return v1 < v2 and not is_equal_approx(v1, v2)

func normalized_angle(value: float, zero_to_full: bool = false):
	var result = value if value >= 0 else value + 2 * PI
	if zero_to_full and is_equal_approx(result, 0.0):
		result = 2 * PI
	return result
	
func normalized_points_angle(point1: Vector2, point2: Vector2, zero_to_full: bool = false):
	return normalized_angle(point1.angle_to_point(point2), zero_to_full)

#Points array routine
func points_wrapp_rect(points: Array[Vector2]) -> Rect2:
	if points.is_empty(): return Rect2(0, 0, 0, 0)
	
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

func first_near(points: Array[Vector2], target: Vector2, tolerance: float) -> Variant:
	var filter = func(p): return (p - target).length() <= tolerance
	var filtered = points.filter(filter)
	return null if filtered.is_empty() else filtered.front()

#Curve routine
func translated_curve(curve: Curve2D, delta: Vector2) -> Curve2D:
	var new_curve = Curve2D.new()
	for index in curve.point_count:
		var point = curve.get_point_position(index) + delta
		new_curve.add_point(point, curve.get_point_in(index), curve.get_point_out(index))
	return new_curve

func rotated_curve(curve: Curve2D, angle: float, anchor: Vector2 = Vector2.ZERO) -> Curve2D:
	var new_curve = Curve2D.new()
	for index in curve.point_count:
		var point = (curve.get_point_position(index) - anchor).rotated(angle) + anchor
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

func curve_points_wrapp_rect(curve: Curve2D) -> Rect2:
	var points: Array[Vector2] = []
	for index in curve.point_count - 1:
		points.append(curve.get_point_position(index))
	return points_wrapp_rect(points)

#Combinations
func combinations(values: Array, size: int) -> Array:
	if size > values.size(): return []
	if size == 1: 
		return values.duplicate().map(func(v): return [v])
	
	var result := []
	var unhandled = values.duplicate()
	while not unhandled.is_empty():
		var head = unhandled.pop_back()
		for sub_combination in combinations(unhandled, size - 1):
			sub_combination.append(head)
			result.append(sub_combination)
			
	return result
