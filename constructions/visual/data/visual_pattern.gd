class_name CVE_VisualPattern extends RefCounted

enum Direction {FORWARD, LEFT, RIGHT}

var code: Array[Direction] = []
var skip: int
var points_overlap: int
var curve: Curve2D

func _init(_code: Array[Direction], _skip: int, _overplap: int, _curve: Curve2D):
	code = _code
	skip = _skip
	points_overlap = _overplap
	curve = _curve
	

func apply(out_curve: Curve2D, scale: float):
	var relative_zero = out_curve.get_point_position(out_curve.point_count)
	for index in curve.point_count:
		var position = curve.get_point_position(index) * scale + relative_zero
		var point_in = curve.get_point_in(index) * scale
		var point_out = curve.get_point_out(index) * scale
		out_curve.add_point(position, point_in, point_out)
			
static func base():
	var base_curve = Curve2D.new()
	base_curve.add_point(Vector2.ZERO)
	base_curve.add_point(Vector2(1, 0))
	return CVE_VisualPattern.new([Direction.FORWARD], 0, 1, base_curve)

#TODO: Remove test patterns
static func demo1():
	var demo_code = [Direction.FORWARD, Direction.LEFT]
	var demo_curve = Curve2D.new()
	demo_curve.add_point(Vector2.ZERO, Vector2.ZERO, Vector2(1, 0))
	demo_curve.add_point(Vector2(1, -1), Vector2(0, 1))
	return CVE_VisualPattern.new(demo_code, 0, 2, demo_curve)
