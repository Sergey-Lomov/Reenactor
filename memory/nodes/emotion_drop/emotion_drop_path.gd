class_name MN_EmotionDropPath extends Path2D

signal completed

var follow: PathFollow2D
var drop: MN_EmotionDrop

func _init():
	follow = PathFollow2D.new()
	follow.loop = false
	add_child(follow)

var state: MN_EmotionDropPathState:
	set(value):
		if state: state.state_updated.disconnect(on_state_updated)
		state = value
		if state: state.state_updated.connect(on_state_updated)
		handle_state_update()

func _process(delta):
	state.progress += state.speed * delta

func handle_state_update():
	handle_drop_update()
	handle_curve_update()
	handle_progress_update()
	
func handle_curve_update():
	curve = state.curve
	
func handle_progress_update():
	follow.progress = state.progress
	if is_equal_approx(follow.progress_ratio, 1.0):
		completed.emit()

func handle_drop_update():
	if drop: follow.remove_child(drop)
	drop = MN_EmotionDrop.new()
	drop.state = state.drop
	drop.radius = MN_EmotionDrop.default_radius
	follow.add_child(drop)

func on_state_updated(update, _old, _new):
	match update:
		MN_EmotionDropPathState.Update.PROGRESS: handle_progress_update()
		MN_EmotionDropPathState.Update.DROP: handle_drop_update()
		MN_EmotionDropPathState.Update.CURVE: handle_curve_update()
