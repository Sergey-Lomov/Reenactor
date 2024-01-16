class_name CVE_VisualPattern extends Resource

enum Direction {FORWARD, LEFT, RIGHT}

@export var title: String = "Unnamed"
@export var pre_requirement: Array[Vector2] = []
@export var requirement: Array[Vector2] = []
@export var post_requirement: Array[Vector2] = []
@export var curve: Curve2D

var full_requirements: Array[Vector2]:
	get:
		return pre_requirement + requirement + post_requirement
		
var center: Vector2:
	get:
		var points = full_requirements
		var x_coords = points.map(func(p): return p.x)
		var y_coords = points.map(func(p): return p.y)
		var center_x = (x_coords.min() + x_coords.max()) / 2
		var center_y = (y_coords.min() + y_coords.max()) / 2
		return Vector2(center_x, center_y)

func _init(_pre_requirement: Array[Vector2] = [], _requirement: Array[Vector2] = [], _post_requirement: Array[Vector2] = [], _curve: Curve2D = Curve2D.new(), _title: String = ""):
	requirement = _requirement
	pre_requirement = _pre_requirement
	post_requirement = _post_requirement
	curve = _curve
	if _title != "": title = _title
	
func check(keypoints: Array[CVE_Keypoint], keypoint_index: int, scale: float) -> bool:	
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

func duplcate() -> CVE_VisualPattern:
	var new = CVE_VisualPattern.new(pre_requirement.duplicate(), requirement.duplicate(), post_requirement.duplicate(), curve.duplicate())
	new.title = title
	return new

func rotated(angle: float) -> CVE_VisualPattern:
	var new_requirement: Array[Vector2] = []
	new_requirement.assign(requirement.map(func(p): return p.rotated(angle)))
	var new_pre_requirement: Array[Vector2] = []
	new_pre_requirement.assign(pre_requirement.map(func(p): return p.rotated(angle)))
	var new_post_requirement: Array[Vector2] = []
	new_post_requirement.assign(post_requirement.map(func(p): return p.rotated(angle)))
	
	var new_curve = Curve2D.new()
	for index in curve.point_count:
		var point = curve.get_point_position(index).rotated(angle)
		var point_in = curve.get_point_in(index).rotated(angle)
		var point_out = curve.get_point_out(index).rotated(angle)
		new_curve.add_point(point, point_in, point_out)
	
	return CVE_VisualPattern.new(new_pre_requirement, new_requirement, new_post_requirement, new_curve)

func mirrored() -> CVE_VisualPattern:
	var new_requirement: Array[Vector2] = []
	new_requirement.assign(requirement.map(func(p): return Vector2(p.x, -p.y)))
	var new_pre_requirement: Array[Vector2] = []
	new_pre_requirement.assign(pre_requirement.map(func(p): return Vector2(p.x, -p.y)))
	var new_post_requirement: Array[Vector2] = []
	new_post_requirement.assign(post_requirement.map(func(p): return Vector2(p.x, -p.y)))
	
	var new_curve = Curve2D.new()
	for index in curve.point_count:
		var point = curve.get_point_position(index)
		point.y = -point.y
		var point_in = curve.get_point_in(index)
		point_in.y = -point_in.y
		var point_out = curve.get_point_out(index)
		point_out.y = -point_out.y
		new_curve.add_point(point, point_in, point_out)
		
	return CVE_VisualPattern.new(new_pre_requirement, new_requirement, new_post_requirement, new_curve)
"""
func inverted() -> CVE_VisualPattern:
	var new_requirement = requirement.duplicate()
	new_requirement.reverse()
	var new_pre_requirement = post_requirement.duplicate()
	new_pre_requirement.reverse()
	var new_post_requirement = pre_requirement.duplicate()
	new_post_requirement.reverse()
	
	if not new_pre_requirement.is_empty():
		var last_new_pre_requirement = new_pre_requirement[new_pre_requirement.size() - 1]
		new_pre_requirement.remove_at(new_pre_requirement.size() - 1)
		new_requirement.insert(0, last_new_pre_requirement)
		
	var last_new_requirement = new_requirement[new_requirement.size() - 1]
	new_requirement.remove_at(new_requirement.size() - 1)
	new_post_requirement.insert(0, last_new_requirement)
	
	var new_curve = Curve2D.new()
	var index = curve.point_count - 1
	while index >= 0:
		new_curve.add_point(curve.get_point_position(index), curve.get_point_out(index), curve.get_point_in(index))
		index -= 1
		
	return CVE_VisualPattern.new(new_pre_requirement, new_requirement, new_post_requirement, new_curve)
"""

static func base() -> CVE_VisualPattern:
	var base_curve = Curve2D.new()
	base_curve.add_point(Vector2.ZERO)
	base_curve.add_point(Vector2(1, 0))
	return CVE_VisualPattern.new([], [Vector2.ZERO, Vector2(1, 0)], [], base_curve, "Base")
