@tool
class_name CVE_PatternsLibraryRow extends Control

@export var title_path: NodePath
@onready var title := get_node(title_path) as Label
@export var previews_box_path: NodePath
@onready var previews_box := get_node(previews_box_path) as HBoxContainer

const title_stub := "Missed"

var pattern: CVE_VisualPattern:
	set(value):
		pattern = value
		if is_node_ready():
			handle_pattern_update()

func _ready():
	if pattern:
		handle_pattern_update()

func handle_pattern_update():
	if not pattern:
		title.text = title_stub
		set_previews_hidden(true)
		return
	
	set_previews_hidden(true)
	title.text = pattern.title
	for index in previews_box.get_child_count():
		var preview = previews_box.get_child(index) as CVE_PatternPreview
		if not preview: continue
		var version: CVE_VisualPattern = pattern if index < 4 else pattern.mirrored()
		preview.pattern = version.rotated(index * PI / 2)

func set_previews_hidden(value: bool):
	for child in previews_box.get_children():
		if not child is CVE_PatternPreview: continue
		if value:
			(child as CVE_PatternPreview).show()
		else:
			(child as CVE_PatternPreview).hide()
