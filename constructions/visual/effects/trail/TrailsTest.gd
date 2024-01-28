extends Node2D

func _input(event):
	#if event is InputEventMouseButton:
	#	if not event.is_pressed(): return
	if event is InputEventMouseMotion:
		for child in get_children():
			var trail := child as VE_Trail
			if not trail: continue
			trail.add_point(event.position)
