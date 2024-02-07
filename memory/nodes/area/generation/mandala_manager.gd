class_name MandalaManager extends Node

var sectors: int
var mirroring: bool
var size: Vector2
var center: Vector2:
	get: return size / 2
var sector_step: float:
	get: return PI * 2 / sectors

const control_distance_mult: float = 0.35
const free_spaces_search_step: float = 0.05
const free_spaces_center_gap: float = 0.2		#Minimal gap between free space area and center. Multiplies by mandala radius.
const free_spaces_edge_gap: float = 0.1			#Minimal gap between free space area and circle outer edge. Multiplies by mandala radius.

const random_count: int = 4						#Points count at randomization
const random_angle_tolerance: float = 1.0		#Max angles difference between new point and last approved point. Multiplies to sector angle.
const random_length_tolerance: float = 0.75		#Max difference between new point length and radius related to it index. Multiplies to layer height.
const random_min_distance: float = 0.1			#If distance between new point and last approved less thah minimal, new point resolves as invalid and should be re-randomized.
const random_point_retry: int = 10				#Count of re-randomizin new point, in case it is invalid 

class Line:
	var from: Vector2 
	var to: Vector2
	
	var angle: float:
		get: return (to - from).angle()
		
	var rect: Rect2:
		get: return Rect2(from, to - from).abs()
	
	func _init(_from: Vector2, _to: Vector2):
		from = _from
		to = _to

	func connected_to(line: Line) -> bool:
		return from.is_equal_approx(line.from) or from.is_equal_approx(line.to) or to.is_equal_approx(line.from) or to.is_equal_approx(line.to)

	func rect_itersects(line: Line) -> bool:
		return rect.intersects(line.rect)

class NodeFreeSpace:
	var position: Vector2
	var radius: float
	
	func _init(_position: Vector2, _radius: float):
		position = _position
		radius = _radius

func _init(_sectors: int, _mirroring: bool, _size: Vector2):
	sectors = _sectors
	mirroring = _mirroring
	size = _size

#Returns sectors edges angles and mirroringing edges angles if mirroringing enabled
func get_edges_angles() -> Array[float]:
	var edges_angles: Array[float] = []
	for i in sectors * 2:
		if not mirroring and i % 2 == 1: continue
		edges_angles.append(i * PI / sectors)
	return edges_angles

#Returns angle of first uniq area (sector or half-sector if mirroringing enabled)
func uniq_angle() -> float:
	var mirroringing_mult = 0.5 if mirroring else 1.0
	return PI * 2 / sectors * mirroringing_mult

#Check is point in specified area. Edge value uses asvalid only if mirroringing enabled
#Fuction uniq_angle() should not be used inside this function to avoid unnecessary recalculations at each call
func in_angle_area(point: Vector2, area_angle: float) -> bool:
	var angle = AdMath.normalized_angle(point.angle())
	var mirroring_edge = mirroring and is_equal_approx(angle, area_angle)
	var zero_edge = is_zero_approx(angle) or is_zero_approx(angle - 2 * PI)
	return angle < area_angle or mirroring_edge or zero_edge

func random_points() -> Array[Vector2]:
	var edges_angles = get_edges_angles()
	var max_radius = size.x / 2.0
	var layer_height = max_radius / random_count
	var min_distance = random_min_distance * max_radius
	var points: Array[Vector2] = []
	
	for i in random_count:
		var new_point = null
		var new_point_valid = false
		var retry_counter = 0
		while not new_point_valid and retry_counter < random_point_retry:
			new_point = random_point(i, points, random_count, edges_angles, layer_height, max_radius)
			new_point_valid = validate_new_point(new_point, points, min_distance)
		points.append(new_point)
	
	return points

func random_point(index: int, points: Array[Vector2], total: int, edges_angles: Array[float], layer_height: float, max_radius: float) -> Vector2:
	var angle = 0
	
	if index > 0:
		var preangle = (points[index-1] - center).angle()
		var random = (randf() - 0.5) * 2.0
		var tolerance = PI * 2.0 / sectors * random_angle_tolerance
		angle = preangle + random * tolerance
	if index == total - 1:
		edges_angles.sort_custom(func(a1, a2): return absf(a1 - angle) < absf(a2 - angle))
		angle = edges_angles.front()

	var length_min = layer_height * (index + 0.5 - random_length_tolerance)
	length_min = clampf(length_min, 0, max_radius)
	var length_max = layer_height * (index + 0.5 + random_length_tolerance)
	length_max = clampf(length_max, 0, max_radius)
	
	var length = randf() * (length_max - length_min) + length_min
	if index == total - 1:
		length = max_radius
	
	return Vector2.from_angle(angle) * length + center
	
func validate_new_point(point: Vector2, approved: Array[Vector2], min_distance: float) -> bool:
	for cursor in approved:
		if (point - cursor).length() < min_distance: 
			return false
		
	return true

func curves_for_points(points: Array[Vector2]) -> Array[Curve2D]:
	var curve := curve_for_points(points)
	var mirrored = AdMath.translated_curve(curve, -center)
	mirrored = AdMath.scaled_curve(mirrored, -1, 1)
	mirrored = AdMath.translated_curve(mirrored, center)
	
	var curves: Array[Curve2D] = []
	for i in sectors:
		var angle = sector_step * i
		var rotated = AdMath.rotated_curve(curve, angle, center)
		curves.append(rotated)
		if mirroring:
			var rotated_mirrored = AdMath.rotated_curve(mirrored, angle, center)
			curves.append(rotated_mirrored)
	
	return curves
	
func curve_for_points(points: Array[Vector2]) -> Curve2D:
	var curve := Curve2D.new()
	for index in points.size():
		var prepoint = null if index == 0 else (points[index - 1] as Variant)
		var postpoint = points[index + 1] as Variant if index < points.size() - 1 else null
		var in_pos = in_control(points[index], prepoint, postpoint)
		var out_pos = out_control(points[index], postpoint, in_pos)
		curve.add_point(points[index], in_pos, out_pos)
	
	return curve

func in_control(point: Vector2, prepoint: Variant, postpoint: Variant) -> Vector2:
	if prepoint == null: return Vector2.ZERO
	
	var angle: float = 0
	var length: float = 0
	
	var prepoint_angle = AdMath.normalized_points_angle(prepoint, point)
	var prepoint_length = (point - prepoint).length()
	
	if postpoint == null:
		angle = AdMath.normalized_angle(prepoint_angle + PI, true)
		length = prepoint_length * control_distance_mult
	else:
		var postpoint_angle = AdMath.normalized_points_angle(point, postpoint)
		var postpoint_length = (point - postpoint).length()
		var average_angle = (prepoint_angle + postpoint_angle) / 2.0
		if abs(prepoint_angle - average_angle) >= PI / 2:
			angle = average_angle
		else:
			angle = average_angle + PI
		angle = AdMath.normalized_angle(angle, true)
		length = (prepoint_length + postpoint_length) / 2.0 * control_distance_mult
	
	return Vector2.from_angle(angle) * length

func out_control(point: Vector2, postpoint: Variant, in_pos: Variant) -> Vector2:
	if postpoint == null: return Vector2.ZERO
	
	var angle: float = 0;
	var length: float = 0;
	if not in_pos.is_equal_approx(Vector2.ZERO):
		angle = in_pos.angle() + PI
		length = in_pos.length()
	else:
		var postpoint_angle = AdMath.normalized_points_angle(point, postpoint)
		angle = AdMath.normalized_angle(postpoint_angle, true);
		length = (point - postpoint).length() * control_distance_mult

	return Vector2.from_angle(angle) * length

func get_intersections(curves: Array[Curve2D]) -> Array[Vector2] :
	var max_angle = uniq_angle()
	var uniq_inters: Array[Vector2] = []

	var lines: Array[Line] = []
	for curve in curves:
		var backed = curve.get_baked_points()
		if backed.size() < 2: continue
		for i in range(1, backed.size()):
			var point_in_sector = in_angle_area(backed[i] - center, max_angle)
			var prepoint_in_sector = in_angle_area(backed[i-1] - center, max_angle)
			if not point_in_sector and not prepoint_in_sector: continue
			lines.append(Line.new(backed[i-1], backed[i]))
	
	var unhandled_lines = lines.duplicate()
	for line in lines:
		unhandled_lines.erase(line)
		for co_line in unhandled_lines:
			if not line.rect_itersects(co_line): continue
			if line.connected_to(co_line): continue
			if is_equal_approx(line.angle, co_line.angle): continue
			
			var p1 = line.from
			var p2 = line.to
			var p3 = co_line.from
			var p4 = co_line.to
			var inter_x_num = (p1.x * p2.y - p2.x * p1.y) * (p3.x - p4.x) - (p1.x - p2.x) * (p3.x * p4.y - p4.x * p3.y)
			var inter_y_num = (p1.x * p2.y - p2.x * p1.y) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x * p4.y - p4.x * p3.y)
			var inter_denom = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x)
			
			var inter_x = inter_x_num / inter_denom
			var inter_y = inter_y_num / inter_denom
			var inter = Vector2(inter_x, inter_y)	
		
			if line.rect.has_point(inter) and co_line.rect.has_point(inter):
				uniq_inters.append(inter)
	
	if mirroring:
		var mirroring_edge = PI / sectors
		var uniq_mirorred: Array[Vector2] = []
		for point in uniq_inters:
			var point_angle = (point - center).angle()
			if is_zero_approx(point_angle) or is_equal_approx(point_angle, mirroring_edge): continue
			var mirrored_angle = mirroring_edge + abs(mirroring_edge - point_angle)
			var mirrored = Vector2.from_angle(mirrored_angle) * (point - center).length() + center
			uniq_mirorred.append(mirrored)
			
		uniq_inters.append_array(uniq_mirorred)
	
	var inters: Array[Vector2] = []

	for point in uniq_inters:
		var relative = point - center
		for i in sectors:
			var sector_angle = i * sector_step
			var new_angle = relative.angle() + sector_angle
			var new_point = Vector2.from_angle(new_angle) * relative.length() + center
			inters.append(new_point)
	
	return inters

func analyze(curves: Array[Curve2D], intersections: Array[Vector2]) -> MandalaMetrics:
	var metrics = MandalaMetrics.new()
	metrics.sectors_count = sectors
	metrics.mirroringing = mirroring
	
	metrics.baked_count = 0
	metrics.baked_length = 0
	for curve in curves:
		metrics.baked_count += curve.get_baked_points().size()
		metrics.baked_length += curve.get_baked_length()
	metrics.baked_interval = curves.front().bake_interval
	
	metrics.intersections_count = intersections.size()
	metrics.intersections_min_distance = INF
	var max_angle = uniq_angle()
	
	for point in intersections:
		if not in_angle_area(point - center, max_angle): continue
		
		var other = intersections.duplicate()
		other.erase(point)
		var distances = other.map(func(p): return (point - p).length())
		distances.sort()		
		metrics.intersections_min_distance = min(metrics.intersections_min_distance, distances.front())
		
		var max_density: float = 0
		for i in distances.size():
			var counts = i + 2
			var area = PI * distances[i] * distances[i]
			max_density = max(max_density, counts / area)
		metrics.intersections_max_density = max_density
	
	metrics.intersections_min_distance = metrics.intersections_min_distance / size.x / 2.0	
	return metrics

func get_free_spaces(curves: Array[Curve2D], required_count: int, min_radius: float) -> Array[NodeFreeSpace]:
	if curves[0].point_count < 2: return []
	var max_angle = uniq_angle() * 3

	var points: Array[Vector2] = []
	for curve in curves:
		var backed = curve.get_baked_points()
		if backed.size() < 2: continue
		for point in backed:
			var point_valid = in_angle_area(point - center, max_angle)
			if point_valid: points.append(point)
	
	var spaces: Array[NodeFreeSpace] = [] 
	var max_radius = size.x / 2.0
	
	var search_angles = [PI * 2 / sectors, PI / sectors]
	if mirroring: 
		search_angles.append(PI * 0.5 / sectors)
		search_angles.append(PI * 1.5 / sectors)
	
	for search_angle in search_angles:
		var basic_vector = Vector2.from_angle(search_angle) * max_radius
		var search_length = free_spaces_search_step
		var angle_spaces: Array[NodeFreeSpace] = [] 
		
		var edge_valid_radius =  (1 - free_spaces_edge_gap) * max_radius
		var center_valid_raiuds = free_spaces_center_gap * max_radius
		while AdMath.less_or_equal_approx(search_length, 1.0 - free_spaces_search_step):
			var position = basic_vector * search_length + center
			search_length += free_spaces_search_step
			var radius = points.map(func(p): return (position-p).length()).min()
			var length = (position - center).length()
			
			if AdMath.less_approx(radius, min_radius): continue
			
			var valid_by_center = AdMath.greater_or_equal_approx(length - radius, center_valid_raiuds)
			if not valid_by_center:
				var valid_radius = length - center_valid_raiuds
				if AdMath.less_approx(valid_radius, min_radius): continue
				radius = valid_radius
			
			var valid_by_edge = AdMath.less_or_equal_approx(length + radius, edge_valid_radius)
			if not valid_by_edge:
				var valid_radius = edge_valid_radius - length
				if AdMath.less_approx(valid_radius, min_radius): continue
				radius = valid_radius
			
			var valid_by_intersection = true
			var overlaped: Array[NodeFreeSpace] = []
			for space in angle_spaces:
				var distance = (space.position - position).length()
				var r_sum = space.radius + radius
				if distance > r_sum or is_equal_approx(distance, r_sum): continue
				if space.radius >= radius: 
					valid_by_intersection = false
					break
				else:
					overlaped.append(space)
			
			if valid_by_intersection:
				for space in overlaped:
					angle_spaces.erase(space)
				angle_spaces.append(NodeFreeSpace.new(position, radius))
				
		spaces.append_array(angle_spaces)
	
	if spaces.size() < required_count: return spaces
	
	spaces.sort_custom(func(s1, s2): return s1.radius > s2.radius)
	var combinations = AdMath.combinations(spaces, required_count)	
	if combinations.is_empty(): return spaces
	
	var radius_sum = func(a): return a.reduce(func(sum, space): return sum + space.radius, 0)
	combinations.sort_custom(func(c1, c2): return radius_sum.call(c1) > radius_sum.call(c2))		
	combinations = combinations.filter(func(spaces_set): return not spaces_intersects(spaces_set))
		
	var result: Array[NodeFreeSpace] = []
	result.assign(combinations.front())
	return result

func spaces_intersects(spaces: Array) -> bool:
	for space in spaces:
		for co_space in spaces:
			if space == co_space: continue
			var distance = (space.position - co_space.position).length()
			var radius_sum = space.radius + co_space.radius
			if AdMath.less_approx(distance, radius_sum): return true
	
	return false
	
