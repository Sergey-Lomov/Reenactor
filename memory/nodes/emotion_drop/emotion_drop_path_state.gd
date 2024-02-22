class_name MN_EmotionDropPathState extends BaseState

enum Update {
	NODE_PRIMARY_EMOTION,
	DROP,
	CURVE,
	SPEED,
	PROGRESS,
}

@export var drop: MN_EmotionDropState:
	set(value):
		var old = drop
		if drop: drop.parent = null
		drop = value
		if drop: drop.parent = self
		state_updated.emit(Update.DROP, old, value)
		
@export var curve: Curve2D:
	set(value):
		var old = curve
		curve = value
		state_updated.emit(Update.CURVE, old, value)
		
@export var speed: float:
	set(value):
		var old = speed
		speed = value
		state_updated.emit(Update.SPEED, old, value)
		
@export var progress: float:
	set(value):
		var old = progress
		progress = value
		state_updated.emit(Update.PROGRESS, old, value)

var node_primary_emotion: Emotion.Type:
	get: return (parent as MN_State).primary_emotion

func parent_updates_mapping():
	return {
		MN_State.Update.TRANSMUTATION: Update.NODE_PRIMARY_EMOTION,
	}
