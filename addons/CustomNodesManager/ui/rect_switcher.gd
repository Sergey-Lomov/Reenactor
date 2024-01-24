@tool
class_name RectSwitcher extends Switcher

@export var on_color: Color
@export var off_color: Color

var rect: ColorRect

func _enter_tree():
	super._enter_tree()
	if not rect:
		rect = ColorRect.new()
		rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(rect)
		move_child(rect, 0)

func switch_to_on(_is_initial: bool = false):
	rect.color = on_color
	
func switch_to_off(_is_initial: bool = false):
	rect.color = off_color
