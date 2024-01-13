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

func _on_grid_resized():
	if not is_node_ready(): return
	update_previews_size()

func _on_open_pressed():
	set_pattern(CVE_VisualPattern.demo1())
	
func update_previews_size():
	print("Grid size: ", grid.size)
	var separation = 20#grid.get_theme_constant("hseparation")
	var preview_size = (grid.size.x - (grid.columns - 1) * separation) / grid.columns
	for child in grid.get_children():
		var preview = child as CVE_PatternPreview
		if not preview: continue
		preview.size = Vector2(preview_size, preview_size)
		
func set_pattern(pattern: CVE_VisualPattern):
	title.text = pattern.title
	for child in grid.get_children():
		var preview = child as CVE_PatternPreview
		if not preview: continue
		preview.pattern = pattern
