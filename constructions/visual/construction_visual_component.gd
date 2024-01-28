class_name ConstructionVisualComponent extends Node2D

var visual: ConstructionVisual:
	get:
		var cursor = self
		
		while cursor.get_parent() != null:
			if cursor.get_parent() is ConstructionVisual:
				return get_parent()
			cursor = cursor.get_parent()
			
		printerr("Construction visual component out of visual")
		return null
