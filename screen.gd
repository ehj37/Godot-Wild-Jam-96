class_name Screen

extends Node2D

@export var respawn_point: Marker2D


func reset() -> void:
	var resettable_elements: Array = find_children("*").filter(
		func(n: Node) -> bool: return n.is_in_group("resettable")
	)
	for resettable_element: Node in resettable_elements:
		assert(
			resettable_element.has_method("reset"),
			(
				"Element "
				+ resettable_element.name
				+ " at screen "
				+ name
				+ " is marked as resettable, but does not implement reset"
			)
		)
		resettable_element.call("reset")


func _draw() -> void:
	var screen_bounds_rect: Rect2 = Rect2(320, 180, 320, 180)
	draw_rect(screen_bounds_rect, Color.YELLOW, false, 1.0)


func _enter_tree() -> void:
	ScreenManager.register(self)
