class_name MN_EtherAbsorber extends ShaderRenderable

signal ether_absorbed

const particle_radius := 3.0
const min_core_radius := particle_radius
const max_core_radius := MN_EmotionDrop.default_radius
const border_width := 2.0
const size_gap := Vector2(2.0, 2.0)

var radius: float:
	set(value):
		radius = value
		update_renderer_size()
		
var state: MN_EtherAbsorberState:
	set(value):
		if state: state.state_updated.disconnect(on_state_updated)
		state = value
		if state: state.state_updated.connect(on_state_updated)
		handle_state_update()

var progress: float:
	get: return state.progress
	set(value): state.progress = value

func get_shader() -> Shader:
	return preload("res://memory/nodes/ether_absorber/ether_absorber.gdshader")
	
func get_size() -> Vector2:
	return (Vector2(radius, radius) + size_gap) * 2.0

func update_renderer_size():
	super.update_renderer_size()
	set_renderer_parameter("absorb_distance", radius)

func setup_renderer_constants():
	var color = EmColor.main(Emotion.Type.ETHER)
	
	set_renderer_parameter("zoom", 1.0)
	set_renderer_parameter("core_border", border_width)
	set_renderer_parameter("main_color", color)
	set_renderer_parameter("particle_border", border_width)
	set_renderer_parameter("particle_radius", particle_radius)
	set_renderer_parameter("center", Vector2.ZERO)
	
func _process(delta):
	var growth = delta / state.drop_duration
	if (progress + growth) < 1:
		progress += growth
	else:
		ether_absorbed.emit()
		progress = state.progress + growth - floor(progress + growth)

func handle_state_update():
	handle_emotion_update()
	handle_geometry_update()
	handle_particles_update()

func handle_emotion_update():
	var border_color = EmColor.mandala(state.primary_emotion)
	set_renderer_parameter("border_color", border_color)
	
func handle_geometry_update():
	set_renderer_parameter("mid_angle", state.orientation)
	set_renderer_parameter("absorb_sector", state.sector)
	
func handle_particles_update():
	set_renderer_parameter("particle_absorb_duration", state.particle_duration)
	set_renderer_parameter("particles_count", state.particles_count)

func handle_progress_update():
	var core_radius = lerpf(min_core_radius, max_core_radius, progress) 
	set_renderer_parameter("core_radius", core_radius)

func on_state_updated(update, _old, _new):
	match update:
		MN_EtherAbsorberState.Update.PRIMARY_EMOTION: handle_emotion_update()
		MN_EtherAbsorberState.Update.ORIENTATION, MN_EtherAbsorberState.Update.SECTOR: handle_geometry_update()
		MN_EtherAbsorberState.Update.PARTICLES_COUNT, MN_EtherAbsorberState.Update.PARTICLE_DURATION: handle_particles_update()
		MN_EtherAbsorberState.Update.PROGRESS: handle_progress_update()
