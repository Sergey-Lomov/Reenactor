class_name World extends Node2D

const structure_visual = preload("res://structures/visualization/StructureVisualization.tscn")

#TODO: possbile unused signal
signal structure_prespawned(StructureVizualization)

func spawAtSpace(structure: Structure, coords: Vector2, direction: float):
	var context = StructureFeatureContext.new()
	context.structure_spawn_requested.connect(_on_structure_feature_context_structure_spawn_requested)
	
	var visual = StructureVisualization.new(structure, context)
	visual.position = coords
	visual.rotation = direction
	structure_prespawned.emit(visual)
	add_child(visual)


func _on_structure_feature_context_structure_spawn_requested(structure, point, direction):
	spawAtSpace(structure, point, direction)
