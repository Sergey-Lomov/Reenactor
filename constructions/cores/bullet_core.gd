class_name SN_BulletCore extends StructureCore

var lifetime: float = 0
const max_durability: float = 1

func _init(_lifetime: float = 0, _durability: float = max_durability):
	lifetime = _lifetime
	durability = _durability

func _process(delta):
	if parent_structure == null:
		return
	
	lifetime -= delta
	if lifetime <= 0:
		parent_structure.request_selfdestruction()

func copy():
	return SN_BulletCore.new(lifetime, durability)
