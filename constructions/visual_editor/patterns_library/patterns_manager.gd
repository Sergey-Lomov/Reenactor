@tool
extends Node

const patterns_dir_path = "res://constructions/visual_editor/patterns/"
const path_separator = "/"

func get_styles_list() -> Array[String]:
	var styles: Array[String] = []
	var dir = DirAccess.open(patterns_dir_path)
	if not dir:
		printerr("Visual patterns directory unavailable.")
		return []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			styles.append(file_name)
		file_name = dir.get_next()
		
	return styles

func get_patterns(style: String) -> Array[CVE_VisualPattern]:
	var patterns: Array[CVE_VisualPattern] = []
	var style_path = patterns_dir_path + style + path_separator
	var dir = DirAccess.open(style_path)
	if not dir:
		printerr("Visual patterns style directory unavailable: ", style)
		return []
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir():
			var pattern_path = style_path + file_name
			var pattern = load(pattern_path)
			if not pattern:
				printerr("Visual patterns file unavailable: ", pattern_path)
				continue
			patterns.append(pattern)	
					
		file_name = dir.get_next()
	
	return patterns
