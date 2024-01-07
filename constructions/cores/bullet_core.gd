class_name SN_BulletCore extends SN_Core

var lifetime: float = 0
const max_durability: float = 1

func _init(_lifetime: float = 0, _durability: float = max_durability):
	super._init(_durability)
	lifetime = _lifetime

func _process(delta):
	if parent_structure == null:
		return
	
	lifetime -= delta
	if lifetime <= 0:
		parent_structure.request_destruction()

func copy():
	return SN_BulletCore.new(lifetime, durability)
