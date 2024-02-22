class_name MN_EmotionDropPathState extends BaseState

enum Param {
	NODE_PRIMARY_EMOTION,
	DROP,
	CURVE,
	SPEED,
	PROGRESS,
}

@export var drop: MN_EmotionDropState:
	set(value):
		if drop: drop.parent = null
		drop = value
		if drop: drop.parent = self
		value_chagned.emit(Param.DROP)
		
@export var curve: Curve2D:
	set(value):
		curve = value
		value_chagned.emit(Param.CURVE)
		
@export var speed: float:
	set(value):
		speed = value
		value_chagned.emit(Param.SPEED)
		
@export var progress: float:
	set(value):
		progress = value
		value_chagned.emit(Param.PROGRESS)

var node_primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion

func parent_parameters_mapping():
	return {
		MN_State.Param.TRANSMUTATION: Param.NODE_PRIMARY_EMOTION,
	}
