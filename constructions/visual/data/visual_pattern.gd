class_name CVE_VisualPattern extends RefCounted

enum Direction {FORWARD, LEFT, RIGHT}

var title: String = "Unnamed"
var pre_requirement: Array[Vector2] = []
var requirement: Array[Vector2] = []
var post_requirement: Array[Vector2] = []
var curve: Curve2D

var full_requirements: Array[Vector2]:
	get:
		return pre_requirement + requirement + post_requirement

func _init(_pre_requirement: Array[Vector2], _requirement: Array[Vector2], _post_requirement: Array[Vector2], _curve: Curve2D, _title: String = ""):
	requirement = _requirement
	pre_requirement = _pre_requirement
	post_requirement = _post_requirement
	curve = _curve
	if _title != "": title = _title
	
func check(keypoints: Array[CVE_Keypoint], keypoint_index: int, scale: float):	
	var main_point = keypoints[keypoint_index]
	var sequence = pre_requirement.duplicate()
	sequence.append_array(requirement)
	sequence.append_array(post_requirement)
	sequence = sequence.map(func(r): return r * scale)
	sequence = sequence.map(func(r): return (r as Vector2).rotated(main_point.direction))
	sequence = sequence.map(func(r): return r + main_point.position)
		
	keypoint_index -= pre_requirement.size()
	keypoint_index = keypoint_index if keypoint_index >= 0 else keypoints.size() + keypoint_index
	if keypoint_index < 0: return false	
		
	for required_coords in sequence:
		var keypoint_coords = keypoints[keypoint_index].position
		if not keypoint_coords.is_equal_approx(required_coords): 
			return false		
		keypoint_index = keypoint_index + 1 if keypoint_index < keypoints.size() - 1 else 0
		
	return true

func apply(out_curve: Curve2D, direction: float, scale: float):
	var relative_zero = out_curve.get_point_position(out_curve.point_count - 1)
	for index in curve.point_count:
		var position = curve.get_point_position(index).rotated(direction) * scale + relative_zero
		var point_in = curve.get_point_in(index).rotated(direction) * scale
		var point_out = curve.get_point_out(index).rotated(direction) * scale
		out_curve.add_point(position, point_in, point_out)
			
static func base():
	var base_curve = Curve2D.new()
	base_curve.add_point(Vector2.ZERO)
	base_curve.add_point(Vector2(1, 0))
	return CVE_VisualPattern.new([], [Vector2.ZERO], [], base_curve, "Base")

#TODO: Remove test patterns
static func demo1():
	var demo_requirement: Array[Vector2] = [Vector2.ZERO, Vector2(1, 0)]
	var demo_post_requirement: Array[Vector2] = [Vector2(1, -1)]
	var demo_curve = Curve2D.new()
	demo_curve.add_point(Vector2(0, 0), Vector2.ZERO, Vector2(0.5, 0))
	demo_curve.add_point(Vector2(1, -1), Vector2(0, 0.5))
	return CVE_VisualPattern.new([], demo_requirement, demo_post_requirement, demo_curve, "Demo 1")
