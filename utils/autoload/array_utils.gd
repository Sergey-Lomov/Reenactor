extends Node

func front_where(array: Array, filter: Callable) -> Variant:
	var results = array.duplicate()
	results.filter(filter)
	return null if results.is_empty() else results.front()
