class_name SN_PlayerController extends SN_Navigator

func affected_absolute_vector(vector: Vector2):
	return vector + Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
func affected_rotation(rotation: float):
	var construction := parent_structure.construction
	if not construction: return rotation
	var mouse_position := get_viewport().get_mouse_position()
	var direction_vector := construction.position.direction_to(mouse_position)
	return direction_vector.angle()
