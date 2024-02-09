class_name MN_Area extends Node2D

var state: MN_AreaState
var size: Vector2:
	set(value):
		size = value
		if is_node_ready(): update_components_positions()

var circle: Circle2D

const border_width: float = 10.0

func _enter_tree():
	if not circle:
		circle = Circle2D.new()
		add_child(circle)
		
func _ready():
	handle_state_update()
		
func update_components_positions():
	circle.radius = min(size.x, size.y) / 2.0
	
func handle_state_update():
	circle.color = EmColor.area(state.primary_emotion)
	circle.border_color = EmColor.area_border(state.primary_emotion)
	circle.border_width = border_width
