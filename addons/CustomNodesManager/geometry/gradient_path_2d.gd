@tool
class_name GradientPath2D extends Path2D

@export var fromColor: Color = Color.WHITE
@export var toColor: Color = Color.WHITE
@export var width: float = 2

func _draw():
	if not curve: return
	if curve.get_baked_points().size() < 2: return
	
	if fromColor.is_equal_approx(toColor):
		draw_polyline(curve.get_baked_points(), fromColor, width, true)
		return
	
	var size = curve.get_baked_points().size()
	var colors = PackedColorArray()
	colors.resize(size)
	for index in size:
		var color = fromColor.lerp(toColor, float(index) / size)
		colors[index] = color
	colors.append(toColor)
	
	draw_polyline_colors(curve.get_baked_points(), colors, 10.0, true)
