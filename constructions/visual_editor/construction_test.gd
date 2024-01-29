class_name ConstructionTest extends Node2D

var back_scene: Node

var construction: Construction:
	get: return get_node("World/Construction") as Construction

func _on_back_pressed():
	if back_scene:
		get_tree().root.add_child(back_scene)
		get_tree().root.remove_child(self)
		queue_free()
