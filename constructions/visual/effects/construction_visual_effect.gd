class_name CVE_Effect extends Node2D

var is_finished: bool = false:
	set(value):
		is_finished = value
		if is_finished: finished.emit(self)

signal finished(effect: CVE_Effect)
