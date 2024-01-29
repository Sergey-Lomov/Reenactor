extends Node2D

func _ready():
	for child in get_children():
		var trail := child as CVE_PlasmaTrail
		if not trail: continue
		trail.color = Color.BROWN
		trail.width = 20

func _input(event):
	#if event is InputEventMouseButton:
	#	if not event.is_pressed(): return
	if event is InputEventMouseMotion:
		for child in get_children():
			var trail := child as CVE_Trail
			if not trail: continue
			trail.add_point(event.position)
