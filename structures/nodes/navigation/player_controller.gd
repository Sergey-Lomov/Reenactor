class_name SN_PlayerController extends SN_Navigator

func affected_absolute_vector(vector: Vector2):
	return vector + Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
