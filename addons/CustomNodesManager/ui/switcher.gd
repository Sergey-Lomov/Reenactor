#Abstract switcher, which should be base class for concrete realisations
@tool
class_name Switcher extends Control

@export var is_on := false:
	set(value):
		is_on = value
		update()

var handler: ColorRect

func _enter_tree():
	if not handler:
		handler = ColorRect.new()
		handler.color = Color(Color.WHITE, 0)
		handler.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(handler)

func _ready():
	update(true)

func _input(event):
	var mouse_event = event as InputEventMouseButton
	if not mouse_event: return
	if handler.get_global_rect().has_point(mouse_event.position):
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			is_on = not is_on
	
func update(is_initial: bool = false):
	switch_to_on(is_initial) if is_on else switch_to_off(is_initial)
	
#Should be overrided by derived class
func switch_to_on(_is_initial: bool = false):
	pass
	
#Should be overrided by derived class
func switch_to_off(_is_initial: bool = false):
	pass
