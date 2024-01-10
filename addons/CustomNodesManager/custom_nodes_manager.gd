@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("Circle2D", "Node2D", preload("geometry/circle_2d.gd"), null)
	add_custom_type("Rectangle2D", "Node2D", preload("geometry/rectangle_2d.gd"), null)
	add_custom_type("GradientPath2D", "Path2D", preload("geometry/gradient_path_2d.gd"), null)
	
	add_custom_type("RectSwitcher", "Switcher", preload("ui/rect_switcher.gd"), null)


func _exit_tree():
	remove_custom_type("Circle2D")
	remove_custom_type("Rectangle2D")
	remove_custom_type("GradientPath2D")
	
	remove_custom_type("RectSwitcher")
