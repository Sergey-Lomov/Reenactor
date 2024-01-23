class_name ConstructionTest extends Node2D

var back_scene: Node
var construction: Construction:
	get: return get_children().filter(func(n): return n is Construction).front()

func _on_back_pressed():
	if back_scene:
		get_tree().root.add_child(back_scene)
		get_tree().root.remove_child(self)
