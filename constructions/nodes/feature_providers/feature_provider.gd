class_name SN_FeatureProvider extends StructureNode

signal feature_execution_requested(feature: StructureFeature)

func _init():
	group = StructureNodeGroup.FEATURE_PROVIDER
