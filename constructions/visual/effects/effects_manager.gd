class_name CVE_Manager extends Node

@export var container_path: NodePath
@onready var container := get_node(container_path) as Node2D

#When effect finished it should be removed. But in some case (trails for example) it should stay alive.
#So effect still be not removed until it have protectors or not finished.
#Keys are CVE_Effect, values are Array[Node]
var protectors: Dictionary = {}

func add_protector(effect: CVE_Effect, protector: Node):
	protector.tree_exited.connect(_on_protector_exited_tree.bind(protector))
	if protectors.has(effect):
		protectors[effect].append(protector)
	else:
		protectors[effect] = [protector]
		
func remove_protector(effect: CVE_Effect, protector: Node):
	protectors[effect].erase(protector)
	remove_effect_if_necessary(effect)
	var used = protectors.values().any(func(a): return (a as Array).has(protector))
	if not used: protector.tree_exited.disconnect(_on_protector_exited_tree)

func remove_effect_if_necessary(effect: CVE_Effect):
	if protectors[effect].is_empty() and effect.is_finished:
		remove_effect(effect)
	
func remove_effect(effect: CVE_Effect):
	protectors.erase(effect)
	container.remove_child(effect)
	effect.queue_free()

func add_effect(config: CVE_EffectConfiguration) -> CVE_Effect:
	if not container: return null
	var effect = instantiate_effect(config)
	
	if effect: 
		container.add_child(effect)
		effect.finished.connect(_on_effect_finished.bind(effect))
		
	return effect

func instantiate_effect(config: CVE_EffectConfiguration) -> CVE_Effect:
	match config.get_effect_type():
		CVE_SourceConfiguration.EffectType.TRAIL:
			return instantiate_trail(config)
	
	return null

func instantiate_trail(source_config: CVE_EffectConfiguration) -> CVE_Trail:
	var trail_config = source_config as CVE_TrailConfiguration
	if not trail_config:
		printerr("CVE_EffectConfiguration have TRAIL effect type, but isn't CVE_TrailConfiguration")
		return null
	
	var trail: CVE_Trail
	match trail_config.get_trail_type():
		CVE_TrailConfiguration.TrailType.PLASMA:
			trail = CVE_PlasmaTrail.new()
	
	trail.setup(trail_config)
	return trail 

func _on_protector_exited_tree(protector: Node):
	for effect in protectors.keys():
		protectors[effect].erase(protector)
		remove_effect_if_necessary(effect) 
		
func _on_effect_finished(effect: CVE_Effect):
	if protectors.has(effect):
		if not protectors[effect].is_empty():
			return
	
	protectors.erase(effect)
	container.remove_child(effect)
	effect.queue_free()
