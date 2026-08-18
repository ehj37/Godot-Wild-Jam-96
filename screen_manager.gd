extends Node

signal screen_changed(new_screen_coords: Vector2i)

# Screen coords -> Screen
var _screens: Dictionary
var _current_screen_coords: Vector2i


func global_position_to_screen_coords(global_position: Vector2) -> Vector2i:
	return Vector2i(floori(global_position.x / 320.0), floori(global_position.y / 180.0))


func screen_coords_to_global_position(screen_coords: Vector2i) -> Vector2:
	return Vector2(screen_coords.x * 320, screen_coords.y * 180)


func current_respawn_position() -> Vector2:
	var current_screen: Screen = _screens[_current_screen_coords]
	if !current_screen:
		push_warning(
			"No screen at coords " + str(_current_screen_coords) + ", defaulting respawn point."
		)
		return _default_respawn_position(_current_screen_coords)

	var respawn_point: Marker2D = current_screen.respawn_point
	if !respawn_point:
		push_warning(
			"Screen at coords " + str(_current_screen_coords) + " has no respawn point, defaulting."
		)
		return _default_respawn_position(_current_screen_coords)

	return respawn_point.global_position


func update_from_player_position(global_position: Vector2) -> void:
	var new_screen_coords: Vector2i = global_position_to_screen_coords(global_position)
	if new_screen_coords != _current_screen_coords:
		_current_screen_coords = new_screen_coords
		screen_changed.emit(new_screen_coords)


func register(screen: Screen) -> void:
	var screen_coords: Vector2i = global_position_to_screen_coords(screen.global_position)
	assert(!_screens.has(screen_coords), "Screen at " + str(screen_coords) + " already registered.")

	_screens[screen_coords] = screen


func _default_respawn_position(screen_coords: Vector2i) -> Vector2:
	return Vector2(screen_coords.x * 320 + 160, screen_coords.y * 180 + 90)
