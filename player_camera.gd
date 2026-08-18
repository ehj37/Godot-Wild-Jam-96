extends Camera2D


func _ready() -> void:
	ScreenManager.screen_changed.connect(_snap_to_screen_coords)


func _snap_to_screen_coords(screen_coords: Vector2i) -> void:
	global_position = ScreenManager.screen_coords_to_global_position(screen_coords)
