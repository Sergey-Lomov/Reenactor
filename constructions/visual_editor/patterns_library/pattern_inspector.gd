@tool
class_name CVE_PatternInspector extends Control

@export var file_line_path: NodePath
@onready var file_line := get_node(file_line_path) as LineEdit
@export var title_path: NodePath
@onready var title := get_node(title_path) as Label
@export var grid_path: NodePath
@onready var grid := get_node(grid_path) as GridContainer

func _ready():
	update_previews_size()
	set_pattern(CVE_VisualPattern.base())

func _on_grid_resized():
	if is_node_ready():
		if grid.is_node_ready():
			update_previews_size()

func _on_open_pressed():
	var path = "res://constructions/visual_editor/patterns/%s.tres" % file_line.text
	var pattern :=  load(path)
	if pattern: 
		set_pattern(pattern)
	
func update_previews_size():
	var separation = grid.get_theme_constant("h_separation")
	var preview_size = (grid.size.x - (grid.columns - 1) * separation) / grid.columns
	for index in grid.get_child_count():
		var preview = grid.get_child(index) as CVE_PatternPreview
		if not preview: continue
		preview.custom_minimum_size = Vector2(preview_size, preview_size)
		
func set_pattern(pattern: CVE_VisualPattern):
	title.text = pattern.title
	for index in grid.get_child_count():
		var preview = grid.get_child(index) as CVE_PatternPreview
		if not preview: continue
		var version: CVE_VisualPattern = pattern if index < 4 else pattern.mirrored()
		preview.pattern = version.rotated(index * PI / 2)
