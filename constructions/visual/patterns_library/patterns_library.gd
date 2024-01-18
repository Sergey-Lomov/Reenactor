@tool
class_name CVE_PatternsLibrary extends Control

@export var styles_button_path: NodePath
@onready var styles_button := get_node(styles_button_path) as MenuButton
@export var rows_box_path: NodePath
@onready var rows_box := get_node(rows_box_path) as VBoxContainer

var row_scene := preload("res://constructions/visual/patterns_library/PatternsLibraryRow.tscn")

func _on_styles_button_style_selected(style):
	for row in rows_box.get_children():
		if not row is CVE_PatternsLibraryRow: continue
		rows_box.remove_child(row)
		row.queue_free()
		
	var patterns = CVE_PatternsManager.get_patterns(style)
	for pattern in patterns:
		var row = row_scene.instantiate()
		row.pattern = pattern
		rows_box.add_child(row)
