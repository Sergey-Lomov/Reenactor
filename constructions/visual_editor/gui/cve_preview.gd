@tool
class_name CVE_Preview extends Control

enum KeypointsPositioning {VERTEX, VERTEX_AND_EDGES, DEEPED}
enum Symmetry {NONE, VERTICAL, HORIZONTAL, VERTICAL_AND_HORIZONTAL, RADIAL}

@export var back_path: NodePath = NodePath("ConstructionBackground")
@onready var back := get_node(back_path) as ConstructionBackground

const material_export_path = "res://experimental/costruction_background/construction_background_test.tres"

var show_grid: bool = false
var grid_size: int = 0
var grid: Array = []
var cell_size: float = 20

var keypoints: Array[CVE_Keypoint] = []
var keypoints_positioning := KeypointsPositioning.VERTEX_AND_EDGES	#Algoraithm not ready to use undeeped keypoints
const angle_delta := 0.01

var patterns: Dictionary = {}
var available_patterns: Array[CVE_VisualPattern] = []
var h_symmetry := false
var v_symmetry := false
var r_symmetry := false

var keypoints_scale: float: #Ratio between inter-keypoints space and cell_size
	get:
		match keypoints_positioning:
			KeypointsPositioning.VERTEX:
				return 1.0
			KeypointsPositioning.VERTEX_AND_EDGES:
				return 0.5
			KeypointsPositioning.DEEPED:
				return 0.5
		return 1.0

var symmetry: Symmetry:
	get: 
		if h_symmetry and v_symmetry:
			return Symmetry.VERTICAL_AND_HORIZONTAL
		elif r_symmetry:
			return Symmetry.RADIAL
		elif v_symmetry:
			return Symmetry.VERTICAL
		elif h_symmetry:
			return Symmetry.HORIZONTAL
		else:
			return Symmetry.NONE

#Debug configuration
var show_keypoints := true
var show_keypoints_directions := true
var show_patterns_edges := true
var show_symmetries := true

func _ready():
	back.size = custom_minimum_size

func _draw():
	if keypoints.is_empty(): return
	
	var curve = Curve2D.new()
	curve.add_point(keypoints[0].position)
	for keypoint in keypoints:
		if patterns.has(keypoint):
			patterns[keypoint].apply(curve, keypoint.direction, cell_size * keypoints_scale)
	
	if curve.point_count >= 2:
		back.curve = curve
		#print(curve.get_baked_points().size())
		#draw_polyline(curve.get_baked_points(), Color.CORNFLOWER_BLUE, 1, true)

	if show_keypoints:
		for keypoint in keypoints:
			draw_circle(keypoint.position, 2, Color.DARK_CYAN)
			if show_keypoints_directions:
				var to = keypoint.position + 3 * Vector2.from_angle(keypoint.direction)
				draw_line(keypoint.position, to, Color.DARK_CYAN, 1, true)
	
	if show_patterns_edges:
		for keypoint in patterns:
			draw_circle(keypoint.position, 2, Color.YELLOW)
			if show_keypoints_directions:
				var to = keypoint.position + 3 * Vector2.from_angle(keypoint.direction)
				draw_line(keypoint.position, to, Color.YELLOW, 1, true)
	
	if show_keypoints:
		draw_circle(keypoints[0].position, 2, Color.RED)
		if show_keypoints_directions:
				var to = keypoints[0].position + 3 * Vector2.from_angle(keypoints[0].direction)
				draw_line(keypoints[0].position, to, Color.RED, 1, true)
		
	if show_symmetries:
		var v_color = Color.WEB_GREEN if v_symmetry else Color.BLACK
		var h_color = Color.WEB_GREEN if h_symmetry else Color.FIREBRICK
		var c_color = Color.WEB_GREEN if r_symmetry else Color.FIREBRICK
		draw_line(Vector2(5, 5), Vector2(5, 25), v_color, 2, true)
		draw_line(Vector2(15, 15), Vector2(35, 15), h_color, 2, true)
		draw_circle(Vector2(45, 15), 3, c_color)
		

func switch_debug():
	show_keypoints = not show_keypoints
	show_patterns_edges = not show_patterns_edges
	show_symmetries = not show_symmetries
	queue_redraw()

func update_content(_grid: Array, _size: int):
	grid = _grid
	grid_size = _size
	update_keypoints()
	update_patterns()

	queue_redraw()

func update_keypoints():
	var keypoints_coords: Array[Vector2] = []
	var min_delta = 0.25 if keypoints_positioning == KeypointsPositioning.DEEPED else 0.0
	var mid_delta = 0.5
	var max_delta = 0.75 if keypoints_positioning == KeypointsPositioning.DEEPED else 1.0
	
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
			
			var candidates: Array[Vector2] = []
			if top_left: candidates.append(Vector2(x + min_delta, y + min_delta) * cell_size)
			if top_right: candidates.append(Vector2(x + max_delta, y + min_delta) * cell_size)
			if bottom_left: candidates.append(Vector2(x + min_delta, y + max_delta) * cell_size)
			if bottom_right: candidates.append(Vector2(x + max_delta, y + max_delta) * cell_size)
			
			if keypoints_positioning == KeypointsPositioning.VERTEX_AND_EDGES:
				if not grid_value(x-1, y): candidates.append(Vector2(x + min_delta, y + mid_delta) * cell_size)
				if not grid_value(x, y-1): candidates.append(Vector2(x + mid_delta, y + min_delta) * cell_size)
				if not grid_value(x+1, y): candidates.append(Vector2(x + max_delta, y + mid_delta) * cell_size)
				if not grid_value(x, y+1): candidates.append(Vector2(x + mid_delta, y + max_delta) * cell_size)
			
			for candidate in candidates:
				if not keypoints_coords.has(candidate):
					keypoints_coords.append(candidate)
	
	analyze_symmetry(keypoints_coords)
	setup_keypoints(keypoints_coords)

func grid_value(x: int, y: int):
	if x < 0 or y < 0 or x > grid_size - 1 or y > grid_size - 1: return false
	return grid[x][y]

func analyze_symmetry(coords: Array[Vector2]):
	v_symmetry = true
	h_symmetry = true
	r_symmetry = true
	
	var rect = AdditionalMath.points_wrapp_rect(coords)
	var center = rect.get_center()
	
	for coord in coords:
		if v_symmetry:
			var sym = Vector2(2 * center.x - coord.x, coord.y)
			if not AdditionalMath.points_has_approx(coords, sym):
				v_symmetry = false
				
		if h_symmetry:
			var sym = Vector2(coord.x, 2 * center.y - coord.y)
			if not AdditionalMath.points_has_approx(coords, sym):
				h_symmetry = false
				
		if r_symmetry:
			var sym = Vector2(2 * center.x - coord.x, 2 * center.y - coord.y)
			if not AdditionalMath.points_has_approx(coords, sym):
				r_symmetry = false

func setup_keypoints(coords: Array[Vector2]):
	keypoints = []
	if coords.is_empty(): return
	
	sort_coords(coords)
	var direction := initial_direction()		
	var first_point = coords[0]
	var coords_iterator: Vector2 = first_point
	var max_gap = cell_size * keypoints_scale
	
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
	
	if keypoints.is_empty():
		printerr("Keypoints array is empty")
		return
	
	#Displace first point to avoid impossibility to apply pattern, which will finish at first point
	var displacement = 0
	while displacement < keypoints.size():
		var pre_displacement = displacement - 1 if displacement > 0 else keypoints.size() - 1 - displacement
		var start = keypoints[displacement]
		var prestart = keypoints[pre_displacement]
		if start.direction == prestart.direction:
			break
		else:
			displacement += 1
	
	for i in displacement:
		var first_keypoint = keypoints[0]
		keypoints.remove_at(0)
		keypoints.append(first_keypoint)

func initial_direction() -> float:
	match symmetry:
		Symmetry.NONE: return 0
		Symmetry.HORIZONTAL: return 1.5 * PI
		Symmetry.VERTICAL, Symmetry.VERTICAL_AND_HORIZONTAL, Symmetry.RADIAL: return PI
		_: return 0

func sort_coords(coords: Array[Vector2]):
	var center = AdditionalMath.points_wrapp_rect(coords).get_center()
	match symmetry:
		Symmetry.NONE:
			coords.sort_custom(func(c1, c2): return c1.y < c2.y if c1.x == c2.x else c1.x < c2.x)
		Symmetry.HORIZONTAL:
			coords.sort_custom(func(c1, c2): 
				if c1.y == c2.y: return c1.x < c2.x
				if c1.y < center.y and c2.y > center.y: return true
				elif c2.y < center.y and c1.y > center.y: return false
				else: return abs(center.y - c1.y) < abs(center.y - c2.y))
		Symmetry.VERTICAL, Symmetry.VERTICAL_AND_HORIZONTAL, Symmetry.RADIAL:
			coords.sort_custom(func(c1, c2): 
				if c1.x == c2.x: return c1.y > c2.y
				if c1.x < center.x and c2.x > center.x: return true
				elif c2.x < center.x and c1.x > center.x: return false
				else: return abs(center.x - c1.x) < abs(center.x - c2.x))

func update_patterns():
	patterns = {}
	var library = available_patterns.duplicate()
	var mirrored_library = library.map(func(p): return p.mirrored())
	library.append_array(mirrored_library)
	var unavailable_points: Array[CVE_Keypoint] = []
	var pattern_scale = cell_size * keypoints_scale
	
	match symmetry:
		Symmetry.VERTICAL, Symmetry.HORIZONTAL:
			var half_index = floor(keypoints.size() / 2.0)
			unavailable_points.append_array(keypoints.slice(half_index))
		Symmetry.VERTICAL_AND_HORIZONTAL, Symmetry.RADIAL:
			var quarter_index = floor(keypoints.size() / 4.0)
			unavailable_points.append_array(keypoints.slice(quarter_index))
	
	var index = 0
	var patterns_sequence: Array[CVE_VisualPattern] = []
	while unavailable_points.size() < keypoints.size():
		randomize()
		library.shuffle()
		
		var success := false
		for pattern in library:
			if pattern.check(keypoints, index, unavailable_points, pattern_scale):
				apply_pattern(pattern, index, unavailable_points)
				patterns_sequence.append(pattern)
				index += pattern.points_usage
				success = true
				break
				
		if not success:
			var pattern = CVE_VisualPattern.base()
			apply_pattern(pattern, index, unavailable_points)
			patterns_sequence.append(pattern)
			index += pattern.points_usage
	
	match symmetry:
		Symmetry.VERTICAL, Symmetry.HORIZONTAL:
			var half_index = floor(keypoints.size() / 2.0)
			for keypoint in keypoints.slice(half_index):
				unavailable_points.erase(keypoint)
				
			patterns_sequence.reverse()
			apply_patterns_sequence(patterns_sequence, index, unavailable_points, pattern_scale, true)
		Symmetry.VERTICAL_AND_HORIZONTAL, Symmetry.RADIAL:
			var half_index = floor(keypoints.size() / 2.0)
			var quarter_index = floor(keypoints.size() / 4.0)
			for keypoint in keypoints.slice(quarter_index, half_index):
				unavailable_points.erase(keypoint)
			
			var adaptation = symmetry == Symmetry.VERTICAL_AND_HORIZONTAL
			var quarter2 := patterns_sequence.duplicate()
			if symmetry == Symmetry.VERTICAL_AND_HORIZONTAL: quarter2.reverse()
			var adapted_quarter2 := apply_patterns_sequence(quarter2, index, unavailable_points, pattern_scale, adaptation)
			index += adapted_quarter2.reduce(func(sum, p): return sum + p.points_usage, 0)
			
			for keypoint in keypoints.slice(half_index):
				unavailable_points.erase(keypoint)
			var half2 := patterns_sequence + adapted_quarter2
			if symmetry == Symmetry.VERTICAL_AND_HORIZONTAL: half2.reverse()
			apply_patterns_sequence(half2, index, unavailable_points, pattern_scale, adaptation)
			

func apply_pattern(pattern: CVE_VisualPattern, index: Variant, unavailable_points: Array[CVE_Keypoint]):
	patterns[keypoints[index]] = pattern
	for iterator in range(index, index + pattern.points_usage):
		unavailable_points.append(keypoints[iterator])

func apply_patterns_sequence(sequence: Array[CVE_VisualPattern], index: int, unavailable_points: Array[CVE_Keypoint], pattern_scale: float, mirroring: bool) -> Array[CVE_VisualPattern]:
	var adapted_sequence: Array[CVE_VisualPattern] = []
	for pattern in sequence:
		var adapted = pattern.mirrored().inverted_main() if mirroring else pattern.duplcate()
		if adapted.check(keypoints, index, unavailable_points, pattern_scale):
			apply_pattern(adapted, index, unavailable_points)
			adapted_sequence.append(adapted)
			index += adapted.points_usage
		else:
			printerr("Can't apply: ", adapted.title, " requirements: ",  adapted.requirement)
	
	return adapted_sequence

func normalized_angle(value: float, zero_to_full: bool = false):
	var result = value if value >= 0 else value + 2 * PI
	if zero_to_full:
		result = result if abs(result) > angle_delta else 2 * PI
	return result

func _on_resized():
	if is_node_ready():
		var min_size = min(size.x, size.y)
		back.size = Vector2(min_size, min_size)

func _on_save_shader_pressed():
	ResourceSaver.save(back.material, material_export_path)
