class_name World extends Node2D

const structure_visual = preload("res://constructions/Construction.tscn")

@export var cve_manager_path: NodePath
@onready var cve_manager := get_node(cve_manager_path) as CVE_Manager

func spawAtSpace(construction: Construction):
	construction.features_context.construction_spawn_requested.connect(_on_construction_spawn_requested)
	construction.visual.cve_manager = cve_manager
	add_child(construction)

func _on_construction_spawn_requested(construction):
	spawAtSpace(construction)
