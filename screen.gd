class_name Screen

extends Node2D

@export var respawn_point: Marker2D


func _draw() -> void:
	var screen_bounds_rect: Rect2 = Rect2(320, 180, 320, 180)
	draw_rect(screen_bounds_rect, Color.YELLOW, false, 1.0)


func _enter_tree() -> void:
	ScreenManager.register(self)
