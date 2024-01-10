class_name CVE_Preview extends Control

var show_grid: bool = false
var grid_size: int = 0
var grid: Array = []
var cell_size: float = 20

var keypoints: Array[CVE_Keypoint] = []
var debug_step = 1
const angle_delta = 0.01

var patterns: Array[CVE_VisualPattern] = [CVE_VisualPattern.base()]

func _draw():
	"""if not line_points.is_empty():
		#var packed = PackedVector2Array(line_points)
		#draw_polyline(packed, Color.DARK_OLIVE_GREEN, 1, true)
		for index in line_points.size():
			if index == 0: continue
			if index > debug_step: continue
			draw_line(line_points[index-1], line_points[index], Color.DARK_OLIVE_GREEN, 1, true)"""
	var curve = Curve2D.new()

	for keypoint in keypoints:
		var color = Color.RED if keypoint == keypoints[0] else Color.CHARTREUSE
		draw_circle(keypoint.position, 2, color)
		var to = keypoint.position + 3 * Vector2.from_angle(keypoint.direction)
		draw_line(keypoint.position, to, color, 1, true)

func updateContent(_grid: Array, _size: int):
	grid = _grid
	grid_size = _size
	debug_step = 0
	updateKeypoints()
		
	queue_redraw()

func updateKeypoints():
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
			
	setupKeypoints(keypoints_coords)

func grid_value(x: int, y: int):
	if x < 0 or y < 0 or x > grid_size - 1 or y > grid_size - 1: return false
	return grid[x][y]

func setupKeypoints(coords: Array[Vector2]):
	keypoints = []
	if coords.is_empty(): return
	
	coords.sort_custom(func(c1, c2): return c1.y < c2.y if c1.x == c2.x else c1.x < c2.x)
	var first_point = coords[0]
	var keypoints_iterator: CVE_Keypoint
	var coords_iterator: Vector2 = first_point
	keypoints.append(CVE_Keypoint.new(coords_iterator, 0))
	coords.erase(coords_iterator)
	var direction: float = 0
	var max_gap = cell_size * 0.5
	
	var iterations = 0
	while not coords.is_empty():
		var nearest = coords.duplicate().filter(func(p): return coords_iterator.distance_to(p) <= max_gap)
		if nearest.is_empty(): break
		nearest.sort_custom(func(p1, p2):
			var out_direction = normalizedAngle(direction - PI/2)
			var fa1: float = normalizedAngle((p1 - coords_iterator).angle())
			var fa2: float = normalizedAngle((p2 - coords_iterator).angle())
			var a1: float = normalizedAngle(fa1 - out_direction + angle_delta)
			var a2: float = normalizedAngle(fa2 - out_direction + angle_delta)
			var d1: float = coords_iterator.distance_to(p1)
			var d2: float = coords_iterator.distance_to(p2)
			print("Iteration: ", iterations, " out_dir: ", out_direction, " fa1: ", fa1, " fa2: ", fa2, " a1: ", a1, " a2: ", a2, " d1: ", d1, " d2: ", d2)
			return d1 < d2 if abs(a1 - a2) <= angle_delta else a1 < a2)
		
		direction = (nearest[0] - coords_iterator).angle()
		direction = direction if direction >= 0 else direction + 2*PI
		keypoints_iterator = CVE_Keypoint.new(coords_iterator, direction)
		coords_iterator = nearest[0]
		keypoints.append(keypoints_iterator)
		coords.erase(coords_iterator)
		iterations += 1
		
		if first_point != null:
			coords.append(first_point)
			first_point = null
		
	print("Iterations ", iterations)

func normalizedAngle(value: float):
	return value if value >= 0 else value + 2 * PI

func stepForward():
	debug_step += 1
	queue_redraw()
