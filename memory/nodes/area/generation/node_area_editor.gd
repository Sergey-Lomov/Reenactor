class_name NodeAreaEditor extends Control

@export var preview_path: NodePath
@onready var preview := get_node(preview_path) as NAE_Preview
@export var metrics_wrapper_path: NodePath
@onready var metrics_wrapper := get_node(metrics_path) as Control
@export var metrics_path: NodePath
@onready var metrics_container := get_node(metrics_path) as NAE_MetricsContainer

var mirroring: bool = true
var sectors: int = 6:
	set(value):
		sectors = value
		if is_node_ready(): preview.sectors = sectors

var points: Array[Vector2] = []
var dragging_index = null

func _ready():
	preview.sectors = sectors
	
func _process(_delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if dragging_index == null:
			var mouse_position = preview.get_local_mouse_position()
			var point = AdMath.first_near(points, mouse_position, preview.point_radius * 2)
			if point:
				dragging_index = points.find(point)
		else:
			points[dragging_index] = preview.get_local_mouse_position()
			update_view()
	
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging_index = null

func update_view():
	var manager = MandalaManager.new(sectors, mirroring, preview.size)
	var curves = manager.curves_for_points(points)
	var intersections = manager.get_intersections(curves)
	preview.curves = curves
	preview.intersections = intersections
	metrics_container.metrics = manager.analyze(curves, intersections)

func _on_add_point_pressed():
	points.append(preview.size * 0.5)
	update_view()

func _on_controls_pressed():
	preview.show_controls = not preview.show_controls

func _on_marking_pressed():
	preview.show_marking = not preview.show_marking
	
func _on_intersections_pressed():
	preview.show_intersections = not preview.show_intersections
	
func _on_curves_pressed():
	preview.show_curves = not preview.show_curves

func _on_randomize_pressed():
	var manager = MandalaManager.new(sectors, mirroring, preview.size)
	points = manager.random_points()	
	preview.radiuses = manager.random_count
	update_view()

func _on_recalculate_pressed():
	recalculate()

func _on_metrics_pressed():
	metrics_wrapper.visible = not metrics_wrapper.visible
	if metrics_wrapper.visible: recalculate()

func recalculate():
	var manager = MandalaManager.new(sectors, mirroring, preview.size)
	var curves = manager.curves_for_points(points)
	var intersections = manager.get_intersections(curves)
	preview.curves = curves
	preview.intersections = intersections
	metrics_container.metrics = manager.analyze(curves, intersections)
