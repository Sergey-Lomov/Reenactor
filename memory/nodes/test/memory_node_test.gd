extends Node2D

var memory_node: MemoryNode

var node_state = preload("res://memory/nodes/test/memory_node_test_state.tres") 
const node_size := Vector2(700, 700)

func _enter_tree():
	memory_node = MemoryNode.new(node_state)
	memory_node.size = node_size
	add_child(memory_node)
