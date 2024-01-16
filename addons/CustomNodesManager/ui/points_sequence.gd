@tool
class_name PointsSequence extends Control

@export var points: Array[Vector2] = []:					#Points
	set(value):
		points = value
		queue_redraw()

@export var point_radius: float = 3:						#Size of point dot
	set(value):
		point_radius = value
		queue_redraw()

@export var translate: Vector2 = Vector2.ZERO:				#Coords of view center. By default center of view will represents center of coordinates.
	set(value):
		translate = value
		queue_redraw()

@export var coords_scale: float = 1:						#Pixels per corrd
	set(value):
		coords_scale = value
		queue_redraw()

@export var color: Color = Color.BEIGE:						#Default points color
	set(value):
		color = value
		queue_redraw()

@export var show_directions: bool = true:					#Show/hide arrow to next coord
	set(value):
		show_directions = value
		queue_redraw()

var custom_colors: Dictionary = {}:							#Specific points colors
	set(value):
		custom_colors = value
		queue_redraw()
		
var direction_arrow_angle: float = PI / 3:					#Should be less than PI / 2
	set(value):
		direction_arrow_angle = value
		queue_redraw()

func _draw():
	for index in points.size():
		var point = points[index]
		var adapted_point = (point + translate) * coords_scale + get_parent_area_size() / 2
		var point_color = custom_colors[index] if custom_colors.has(index) else color
		draw_circle(adapted_point, point_radius, point_color)
		
		if show_directions and index < points.size() - 1:
			var direction = point.angle_to_point(points[index + 1])
			var p1 = adapted_point + Vector2.from_angle(direction - PI/3) * point_radius
			var p2 = adapted_point + Vector2.from_angle(direction + PI/3) * point_radius
			var cos_a = cos(direction_arrow_angle)
			var sin_a = sin(direction_arrow_angle)
			var arrow_length = point_radius * (cos_a + sin_a * sin_a / cos_a)  
			var p3 = adapted_point + Vector2.from_angle(direction) * arrow_length 
			draw_colored_polygon([p1, p2, p3], point_color)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
