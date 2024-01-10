class_name CVE_Preview extends Control

var show_grid: bool = false
var grid_size: int = 0
var grid: Array = []
var cell_size: float = 20

var source_point: Vector2
var keypoint_coords: Array[Vector2] = []
var line_points: Array[Vector2] = []
var debug_step = 1
const angle_delta = 0.01

func _draw():
	if not line_points.is_empty():
		#var packed = PackedVector2Array(line_points)
		#draw_polyline(packed, Color.DARK_OLIVE_GREEN, 1, true)
		for index in line_points.size():
			if index == 0: continue
			if index > debug_step: continue
			draw_line(line_points[index-1], line_points[index], Color.DARK_OLIVE_GREEN, 1, true)
			
	
	for coord in keypoint_coords:
		draw_circle(coord, 2, Color.CHARTREUSE)
		
	if source_point:
		draw_circle(source_point, 2, Color.RED)

func updateContent(_grid: Array, _size: int):
	grid = _grid
	grid_size = _size
	debug_step = 0
	updateKeypoints()
	updateLine()
		
	queue_redraw()

func updateKeypoints():
	keypoint_coords = []
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
				
			if top_left: keypoint_coords.append(Vector2(x+0.25, y+0.25) * cell_size)
			if top_right: keypoint_coords.append(Vector2(x+0.75, y+0.25) * cell_size)
			if bottom_left: keypoint_coords.append(Vector2(x+0.25, y+0.75) * cell_size)
			if bottom_right: keypoint_coords.append(Vector2(x+0.75, y+0.75) * cell_size)

func grid_value(x: int, y: int):
	if x < 0 or y < 0 or x > grid_size - 1 or y > grid_size - 1: return false
	return grid[x][y]

func updateLine():
	line_points = []
	keypoint_coords.sort_custom(func(c1, c2): return c1.y < c2.y if c1.x == c2.x else c1.x < c2.x)
	if keypoint_coords.size() > 0:
		source_point = keypoint_coords[0]
	
	line_points = [source_point]
	var unhandled = keypoint_coords.duplicate()
	unhandled.erase(source_point)
	var cursor: Vector2 = source_point
	var direction: float = 0
	var max_gap = cell_size * 0.5
	
	var iterations = 0
	while not unhandled.is_empty():
		var nearest = unhandled.duplicate().filter(func(p): return cursor.distance_to(p) <= max_gap)
		if nearest.is_empty(): break
		nearest.sort_custom(func(p1, p2):
			var out_direction = normalizedAngle(direction - PI/2)
			var fa1: float = normalizedAngle((p1 - cursor).angle())
			var fa2: float = normalizedAngle((p2 - cursor).angle())
			var a1: float = normalizedAngle(fa1 - out_direction + angle_delta)
			var a2: float = normalizedAngle(fa2 - out_direction + angle_delta)
			var d1: float = cursor.distance_to(p1)
			var d2: float = cursor.distance_to(p2)
			print("Iteration: ", iterations, " out_dir: ", out_direction, " fa1: ", fa1, " fa2: ", fa2, " a1: ", a1, " a2: ", a2, " d1: ", d1, " d2: ", d2)
			return d1 < d2 if abs(a1 - a2) <= angle_delta else a1 < a2)
		
		direction = (nearest[0] - cursor).angle()
		direction = direction if direction >= 0 else direction + 2*PI
		cursor = nearest[0]
		line_points.append(cursor)
		unhandled.erase(cursor)
		iterations += 1
		
	print("Iterations ", iterations)

func normalizedAngle(value: float):
	return value if value >= 0 else value + 2 * PI

func stepForward():
	debug_step += 1
	queue_redraw()
