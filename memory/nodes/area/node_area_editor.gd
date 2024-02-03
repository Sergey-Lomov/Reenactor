class_name NodeAreaEditor extends Control

@export var preview_path: NodePath
@onready var preview := get_node(preview_path) as NAE_Preview

var mirror: bool = true
var sectors: int = 6:
	set(value):
		sectors = value
		if is_node_ready(): preview.sectors = sectors

const control_distance_mult: float = 0.35

var points: Array[Vector2] = []
var dragging_index = null

func _ready():
	preview.sectors = sectors
	
func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if dragging_index == null:
			var mouse_position = preview.get_local_mouse_position()
			var point = AdMath.first_near(points, mouse_position, preview.point_radius)
			if point:
				dragging_index = points.find(point)
		else:
			points[dragging_index] = preview.get_local_mouse_position()
			update_view()
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_index = null

func update_view():
	var angle_step = PI * 2 / float(sectors)
	var center = preview.size * 0.5
	var curve := curve_for_points()
	var mirrored = AdMath.translated_curve(curve, -center)
	mirrored = AdMath.scaled_curve(mirrored, -1, 1)
	mirrored = AdMath.translated_curve(mirrored, center)
	
	var curves: Array[Curve2D] = []
	for i in sectors:
		var angle = angle_step * i
		var rotated = AdMath.rotated_curve(curve, angle, center)
		curves.append(rotated)
		if mirror:
			var rotated_mirrored = AdMath.rotated_curve(mirrored, angle, center)
			curves.append(rotated_mirrored)
		
	preview.curves = curves

func curve_for_points() -> Curve2D:
	var curve := Curve2D.new()
	for index in points.size():
		var prepoint = null if index == 0 else (points[index - 1] as Variant)
		var postpoint = points[index + 1] as Variant if index < points.size() - 1 else null
		var in_control = random_in_control(points[index], prepoint, postpoint)
		var out_control = random_out_control(points[index], postpoint, in_control)
		curve.add_point(points[index], in_control, out_control)
	
	return curve

func random_in_control(point: Vector2, prepoint: Variant, postpoint: Variant) -> Vector2:
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

func random_out_control(point: Vector2, postpoint: Variant, in_control: Variant) -> Vector2:
	if postpoint == null: return Vector2.ZERO
	
	var angle: float = 0;
	var length: float = 0;
	if not in_control.is_equal_approx(Vector2.ZERO):
		angle = in_control.angle() + PI
		length = in_control.length()
	else:
		var postpoint_angle = AdMath.normalized_points_angle(point, postpoint)
		angle = AdMath.normalized_angle(postpoint_angle, true);
		length = (point - postpoint).length() * control_distance_mult

	return Vector2.from_angle(angle) * length

func _on_add_point_pressed():
	points.append(preview.size * 0.5)
	print("Point added: ", points.back())
	update_view()

func _on_controls_pressed():
	preview.show_controls = not preview.show_controls

func _on_marking_pressed():
	preview.show_marking = not preview.show_marking

