class_name StructureFeatureContext extends Node

signal structure_spawn_requested(structure: Structure, point: Vector2, direction: float)

var construction: Construction:
	get:
		return get_parent() as Construction
		
var is_player_controlled: bool:
	get:
		var controllers = construction.structure.get_children().filter(func(c): return c is SN_PlayerController)
		return not controllers.is_empty()
