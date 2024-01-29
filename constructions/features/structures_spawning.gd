class_name SF_StructuresSpawning extends StructureFeature

enum Direction {
	BY_TARGET,		#Spawned construction direction will be related to direction to target specified by AI or by player control (mouse)
	BY_SPAWNER,		#Spawned construction direction will be related to mother construction direction
}

#TODO: Try to found more glance way to prevent parent and spwaned construiction collision at spawn position
const gap: float = 2 #Additional gap between parent and spwaned construictions to avoid collision at spawn point

var structure: Structure
var visual: ConstructionVisualConfiguration
var custom_team: Variant
var direction_mode: Direction = Direction.BY_TARGET
var additional_angle: float = 0 #Angle relative to direction specified by direction mode

func _init(_structure: Structure, _visual: ConstructionVisualConfiguration, _custom_team: Variant):
	structure = _structure
	custom_team = _custom_team
	visual = _visual

func execute(context: StructureFeatureContext):
	var parent = context.construction
	
	var rotation = 0
	match direction_mode:
		Direction.BY_TARGET:
			if context.is_player_controlled:
				var mouse_position = parent.get_viewport().get_mouse_position()
				var control_vector = parent.position.direction_to(mouse_position)
				rotation = control_vector.angle()
		Direction.BY_SPAWNER:
			rotation = parent.rotation
	rotation += additional_angle
	
	var construction = Construction.new(structure, StructureFeatureContext.new())
	construction.visual.config = visual
	var position = parent.position + Vector2(cos(rotation), sin(rotation)) * (parent.radius + construction.radius + gap)
	construction.position = position
	construction.rotation = rotation
	construction.team = custom_team if custom_team else parent.team
	
	context.construction_spawn_requested.emit(construction)
