class_name NodeAreaEditor extends Control

@export var preview_path: NodePath
@onready var preview := get_node(preview_path) as NAE_Preview
@export var metrics_wrapper_path: NodePath
@onready var metrics_wrapper := get_node(metrics_path) as Control
@export var metrics_path: NodePath
@onready var metrics_container := get_node(metrics_path) as NAE_MetricsContainer
@export var history_info_path: NodePath
@onready var history_info := get_node(history_info_path) as Label

const save_resource_path := "res://memory/nodes/generation/saved_config.tres"
const curves_export_path := "res://memory/nodes/generation/exported_curves.tres"

var mirroring: bool = true
var sectors: int = 6:
	set(value):
		sectors = value
		if is_node_ready(): preview.sectors = sectors

var points: Array[Vector2] = []

class HistoryItem:
	var points: Array[Vector2]
	var sectors: int
	var mirroring: bool
	
	func _init(_points: Array[Vector2], _sectors: int, _mirroring: bool):
		points = _points
		sectors = _sectors
		mirroring = _mirroring
	
var history: Array[HistoryItem] = []
var history_index: int = 0:
	set(value):
		value = clamp(0, history.size() - 1, value)
		if history_index < history.size() - 1:
			history[history_index].points = points.duplicate()
			history[history_index].sectors = sectors
			history[history_index].mirroring = mirroring
		history_index = value
		hande_history_index_update()
		
var dragging_index = null

const free_space_count: int = 3
const free_space_min_radius: float = 0.025

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
	var adapted_min_radius = free_space_min_radius * size.x / 2
	preview.free_spaces = manager.get_free_spaces(curves, free_space_count, adapted_min_radius)

func _on_load_pressed():
	var config = ResourceLoader.load(save_resource_path) as MandalaGenerationConfig
	points = config.points
	sectors = config.sectors
	mirroring = config.mirroring
	update_view()

func _on_save_pressed():
	var config = MandalaGenerationConfig.new(points, sectors, mirroring)
	ResourceSaver.save(config, save_resource_path)

func _on_back_pressed():
	history_index = max(0, history_index - 1)

func _on_next_pressed():
	history_index = min(history.size() - 1, history_index + 1)

func _on_duplicate_pressed():
	var history_item = HistoryItem.new(points, sectors, mirroring)
	history.append(history_item)
	history_index = history.size() - 1

func _on_add_point_pressed():
	points.append(preview.size * 0.5)
	update_view()

func _on_remove_point_pressed():
	points.pop_back()
	update_view()

func _on_controls_pressed():
	preview.show_controls = not preview.show_controls

func _on_marking_pressed():
	preview.show_marking = not preview.show_marking
	
func _on_intersections_pressed():
	preview.show_intersections = not preview.show_intersections
	
func _on_curves_pressed():
	preview.show_curves = not preview.show_curves
	
func _on_spaces_pressed():
	preview.show_spaces = not preview.show_spaces

func _on_randomize_pressed():
	var manager = MandalaManager.new(sectors, mirroring, preview.size)
	var new_points = manager.random_points()	
	preview.radiuses = manager.random_count
	var history_item = HistoryItem.new(new_points, sectors, mirroring)
	history.append(history_item)
	history_index = history.size() - 1
	update_view()

func _on_recalculate_pressed():
	recalculate()

func _on_metrics_pressed():
	metrics_wrapper.visible = not metrics_wrapper.visible
	if metrics_wrapper.visible: recalculate()

func _on_add_sector_pressed():
	sectors += 1
	update_view()
	
func _on_remove_sector_pressed():
	sectors = max(1, sectors-1)
	update_view()
	
func _on_export_curves_pressed():
	var array = CurvesArray.new()
	var curve_scale = Vector2.ONE / preview.size
	for curve in preview.curves:
		var scaled = AdMath.scaled_curve_g(curve, curve_scale)
		var translated = AdMath.translated_curve_s(scaled, -0.5, -0.5)
		array.curves.append(translated)
	ResourceSaver.save(array, curves_export_path)
	
func recalculate():
	update_view()

func update_history_info():
	history_info.text = "%d / %d" % [(history_index + 1), history.size()]

func hande_history_index_update():
	points = history[history_index].points
	sectors = history[history_index].sectors
	mirroring = history[history_index].mirroring
	update_view()
	update_history_info()
