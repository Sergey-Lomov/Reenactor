class_name CVE_Trail extends CVE_Effect

#Class described trail point - coords and lifetime
class PointLifetime:
	var coords: Vector2
	var lifetime: float
	
	func _init(_coords: Vector2, _lifetime: float):
		coords = _coords
		lifetime = _lifetime

var points: Array[PointLifetime] = []

#Point life time
var lifetime: float = 1.0

#Disappearing animation duration. Is part of point lifetime.
var disappearing: float = 0.0:	
	set(value): material.set_shader_parameter("disappearing", value)
	get: return material.get_shader_parameter("disappearing")

#Points wrapping rectangle
var rect: Rect2:
	set(value):
		#TODO: remove test code
		rect = Rect2(0, 0, 1000, 800)#value
		if material: material.set_shader_parameter("texture_size", full_size)
		position = rect.position - get_gap()

#Full size of rendering rect (points wrapping + gaps)
var full_size: Vector2:
	get:
		if rect: return rect.size + get_gap() * 2
		else: return Vector2.ZERO
		
#Should be overrided in dervied classes.
func get_shader() -> Shader:
	return null
	
#Additional randering space around points. May be overrided in dervied classes.
func get_gap() -> Vector2:
	return Vector2.ZERO

#Return value should be equal same value specified in shader. Should be overrided in derived classes.
func get_max_points() -> int:
	return 1

func _init():
	material = ShaderMaterial.new()
	material.shader = get_shader()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, full_size), Color.WHITE)

func _process(delta):
	var dead_point: PointLifetime
	for index in points.size():
		points[index].lifetime -= delta
		if points[index].lifetime <= 0:
			if index > 0: 
				dead_point = points[index - 1]
			elif points.size() == 1:
				dead_point = points[index]
	
	if dead_point: remove_point(dead_point)
	
	var lifetimes = points.map(func(p): return p.lifetime)
	
	material.set_shader_parameter("points_count", points.size())
	material.set_shader_parameter("points", get_coords(true))
	material.set_shader_parameter("lifetimes", lifetimes)
	
	queue_redraw()
		
#Should be overrided by derived class
func setup(config: CVE_TrailConfiguration):
	lifetime = config.lifeatime
	disappearing = config.disappearing
		
func add_point(coord: Vector2):
	var point = PointLifetime.new(coord, lifetime)
	points.push_back(point)
	
	#Urgent point removing without appopriate visualization
	if points.size() > get_max_points(): 
		points.pop_front()	
		
	rect = AdMath.points_wrapp_rect(get_coords())
	is_finished = false
	
func remove_point(point: PointLifetime):
	points.erase(point)
	rect = AdMath.points_wrapp_rect(get_coords())
	if points.is_empty(): is_finished = true

func get_coords(relative: bool = false) -> Array[Vector2]:
	var result: Array[Vector2] = []
	var mapped = (points.map(func(p): 
		if relative: 
			return p.coords - position
		else: 
			return p.coords
	))
	result.assign(mapped)
	return result
