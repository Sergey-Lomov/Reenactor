class_name Game extends Node2D

func _on_world_structure_prespawned(construction: Construction):
	construction.structure.features_list_changed.connect(_on_structure_feature_list_changed)

func _on_structure_feature_list_changed(_providers):
	pass
#	for provider in providers:
#		var type = (provider as SN_FeatureProvider).feature_type
#		match type:
#			StructureFeature.Type.STRUCTURE_SPAWN:
#				provider.construction_spawn_requested.connect(_on_construction_spawn_requested)
