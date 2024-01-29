class_name ConstructionVisualComponent extends Node2D

var visual: ConstructionVisual:
	get:
		var message = "Construction visual component out of visual"
		return NodeUtils.parent_by_type(self, ConstructionVisual, message) as ConstructionVisual
