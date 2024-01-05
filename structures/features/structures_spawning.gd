class_name SF_StructuresSpawning extends StructureFeature

enum Direction {
	BY_TARGET,		#Spawned construction direction will be related to direction to target specified by AI or by player control (mouse)
	BY_SPAWNER,		#Spawned construction direction will be related to mother construction direction
}

var structure: Structure
var direction_mode: Direction = Direction.BY_TARGET
var additional_angle: float = 0 #Angle relative to direction specified by direction mode

func _init(_structure: Structure):
	structure = _structure

func execute(context: StructureFeatureContext):
	var visual = context.visual
	var direction = 0
	match direction_mode:
		Direction.BY_TARGET:
			if context.is_player_controlled:
				var mouse_position = visual.get_viewport().get_mouse_position()
				var control_vector = visual.position.direction_to(mouse_position)
				direction = control_vector.angle()
		Direction.BY_SPAWNER:
			direction = visual.rotation
	
	direction += additional_angle
	var point = visual.position + Vector2(cos(direction), sin(direction)) * visual.radius
	context.structure_spawn_requested.emit(structure, point, direction)
