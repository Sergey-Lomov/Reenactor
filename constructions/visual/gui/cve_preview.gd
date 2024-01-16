class_name CVE_Preview extends Control

var show_grid: bool = false
var grid_size: int = 0
var grid: Array = []
var cell_size: float = 20

var keypoints: Array[CVE_Keypoint] = []
var debug_step: int = 1
const show_keypoints := false
const angle_delta := 0.01
const keypoints_scale := 0.5

var patterns: Dictionary = {}
var patterns_library: Array[CVE_VisualPattern] = [
	CVE_VisualPattern.demo1(),
	]

func _draw():
	if keypoints.is_empty(): return
		
	var curve = Curve2D.new()
	curve.add_point(keypoints[0].position)
	for keypoint in patterns:
		patterns[keypoint].apply(curve, keypoint.direction, cell_size * keypoints_scale)
	
	if curve.point_count >= 2:
		draw_polyline(curve.get_baked_points(), Color.CORNFLOWER_BLUE, 1, true)

	if show_keypoints:
		for keypoint in keypoints:
			var color = Color.CHARTREUSE
			draw_circle(keypoint.position, 2, color)
			var to = keypoint.position + 3 * Vector2.from_angle(keypoint.direction)
			draw_line(keypoint.position, to, color, 1, true)

func update_content(_grid: Array, _size: int):
	grid = _grid
	grid_size = _size
	debug_step = 0
	update_keypoints()
	apply_patterns()

	queue_redraw()

func update_keypoints():
	var keypoints_coords: Array[Vector2] = []
	for x in grid_size:
		for y in grid_size:
			if not grid[x][y]: continue
			
			var top_left = false
			var top_right = false
			var bottom_left = false
			var bottom_right = false
			
			if not grid_value(x-1, y): 
				top_left = true 
				bottom_left = true
				
			if not grid_value(x+1, y): 
				top_right = true 
				bottom_right = true
				
			if not grid_value(x, y-1):
				top_left = true 
				top_right = true
				
			if not grid_value(x, y+1):
				bottom_left = true 
				bottom_right = true
				
			if not grid_value(x+1, y+1): bottom_right = true
			if not grid_value(x-1, y+1): bottom_left = true
			if not grid_value(x+1, y-1): top_right = true
			if not grid_value(x-1, y-1): top_left = true
				
			if top_left: keypoints_coords.append(Vector2(x+0.25, y+0.25) * cell_size)
			if top_right: keypoints_coords.append(Vector2(x+0.75, y+0.25) * cell_size)
			if bottom_left: keypoints_coords.append(Vector2(x+0.25, y+0.75) * cell_size)
			if bottom_right: keypoints_coords.append(Vector2(x+0.75, y+0.75) * cell_size)
			
	setup_keypoints(keypoints_coords)

func grid_value(x: int, y: int):
	if x < 0 or y < 0 or x > grid_size - 1 or y > grid_size - 1: return false
	return grid[x][y]

func setup_keypoints(coords: Array[Vector2]):
	keypoints = []
	if coords.is_empty(): return
	
	coords.sort_custom(func(c1, c2): return c1.y < c2.y if c1.x == c2.x else c1.x < c2.x)
	var first_point = coords[0]
	var coords_iterator: Vector2 = first_point
	var direction: float = 0
	var max_gap = cell_size * 0.5
	
#	var iterations = 0
	while not coords.is_empty():
		coords.erase(coords_iterator)
		
		#TODO: Try to remove duplicate()
		var nearest = coords.duplicate().filter(func(p): return coords_iterator.distance_to(p) <= max_gap)
		if nearest.is_empty(): 
			if not coords_iterator.is_equal_approx(first_point) and coords_iterator.distance_to(first_point) <= max_gap:
				nearest = [first_point]
			else:
				break
			
		nearest.sort_custom(func(p1, p2):
			var out_direction = normalized_angle(direction - PI/2)
			var fa1: float = normalized_angle((p1 - coords_iterator).angle())
			var fa2: float = normalized_angle((p2 - coords_iterator).angle())
			var a1: float = normalized_angle(fa1 - out_direction + angle_delta)
			var a2: float = normalized_angle(fa2 - out_direction + angle_delta)
			var d1: float = coords_iterator.distance_to(p1)
			var d2: float = coords_iterator.distance_to(p2)
#			print("Iteration: ", iterations, " out_dir: ", out_direction, " fa1: ", fa1, " fa2: ", fa2, " a1: ", a1, " a2: ", a2, " d1: ", d1, " d2: ", d2)
			return d1 < d2 if abs(a1 - a2) <= angle_delta else a1 < a2)
		
		#TODO: Change to angle_to and retest
		direction = (nearest[0] - coords_iterator).angle()
		direction = direction if direction >= 0 else direction + 2*PI
		var keypoint = CVE_Keypoint.new(coords_iterator, direction)
		keypoints.append(keypoint)
		coords_iterator = nearest[0]
#		iterations += 1
#	print("Iterations ", iterations)

func apply_patterns():
	patterns = {}
	var index = 0
	var library = patterns_library.duplicate()
	while index < keypoints.size():
		randomize()
		library.shuffle()
		
		var success := false
		for pattern in library:
			if pattern.check(keypoints, index, cell_size * keypoints_scale):
				patterns[keypoints[index]] = pattern
				index += pattern.requirement.size() - 1
				success = true
				break
				
		if not success:
			var pattern = CVE_VisualPattern.base()
			patterns[keypoints[index]] = pattern
			index += pattern.requirement.size() - 1

func normalized_angle(value: float, zero_to_full: bool = false):
	var result = value if value >= 0 else value + 2 * PI
	if zero_to_full:
		result = result if abs(result) > angle_delta else 2 * PI
	return result

func step_forward():
	debug_step += 1
	queue_redraw()
