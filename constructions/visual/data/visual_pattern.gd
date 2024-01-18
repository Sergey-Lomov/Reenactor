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
		
var points_usage: int:
	get:
		return requirement.size() - 1
		
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
	
func check(keypoints: Array[CVE_Keypoint], keypoint_index: int, used_points: Array[CVE_Keypoint], scale: float) -> bool:	
	var main_point = keypoints[keypoint_index]
	var sequence = pre_requirement.duplicate()
	sequence.append_array(requirement)
	sequence.append_array(post_requirement)
	sequence = sequence.map(func(r): return r * scale)
	sequence = sequence.map(func(r): return r.rotated(main_point.direction))
	sequence = sequence.map(func(r): return r + main_point.position)
	
	keypoint_index -= pre_requirement.size()
	keypoint_index = keypoint_index if keypoint_index >= 0 else keypoints.size() + keypoint_index
	if keypoint_index < 0: return false	
	
	for iter in sequence.size():
		var required_coords = sequence[iter]
		var keypoint = keypoints[keypoint_index]
		if not keypoint.position.is_equal_approx(required_coords): 
			return false
		var will_be_used = iter >= pre_requirement.size() and iter < pre_requirement.size() + points_usage
		if will_be_used and used_points.has(keypoint):
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
	var new_requirement := AdditionalMath.rotated_points(requirement, angle)
	var new_pre_requirement := AdditionalMath.rotated_points(pre_requirement, angle)
	var new_post_requirement := AdditionalMath.rotated_points(post_requirement, angle)
	var new_curve := AdditionalMath.rotated_curve(curve, angle)
	var new_title = title + " rotated"
	
	return CVE_VisualPattern.new(new_pre_requirement, new_requirement, new_post_requirement, new_curve, new_title)

func mirrored() -> CVE_VisualPattern:
	var new_requirement := AdditionalMath.scaled_points(requirement, 1, -1)
	var new_pre_requirement := AdditionalMath.scaled_points(pre_requirement, 1, -1)
	var new_post_requirement := AdditionalMath.scaled_points(post_requirement, 1, -1)
	var new_curve := AdditionalMath.scaled_curve(curve, 1, -1)
	var new_title = title + " mirrored"
	
	return CVE_VisualPattern.new(new_pre_requirement, new_requirement, new_post_requirement, new_curve, new_title)

#Return pattern with inverted directions, but only with main requirement. Post and pre requirements will be removed.
func inverted_main() -> CVE_VisualPattern:
	var new_requirement := AdditionalMath.translated_points(requirement, -requirement.back())
	new_requirement.reverse()
	var angle = -new_requirement[1].angle()
	
	new_requirement = AdditionalMath.rotated_points(new_requirement, angle)
	
	var last_position = curve.get_point_position(curve.point_count - 1)
	var new_curve := AdditionalMath.translated_curve(curve, -last_position)
	new_curve = AdditionalMath.reversed_curve(new_curve)
	new_curve = AdditionalMath.rotated_curve(new_curve, angle)
	
	var new_title = title + " inverted_main"
	return CVE_VisualPattern.new([], new_requirement, [], new_curve, new_title)

static func base() -> CVE_VisualPattern:
	var base_curve = Curve2D.new()
	base_curve.add_point(Vector2.ZERO)
	base_curve.add_point(Vector2(1, 0))
	return CVE_VisualPattern.new([], [Vector2.ZERO, Vector2(1, 0)], [], base_curve, "Base")
