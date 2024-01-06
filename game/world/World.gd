class_name World extends Node2D

const structure_visual = preload("res://constructions/Construction.tscn")

func spawAtSpace(construction: Construction):
	construction.features_context.construction_spawn_requested.connect(_on_construction_spawn_requested)
	add_child(construction)

func _on_construction_spawn_requested(construction):
	spawAtSpace(construction)
