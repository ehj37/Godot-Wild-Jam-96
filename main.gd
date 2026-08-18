@tool

extends Node2D

@export var add_screens: bool = false:
	set(new_value):
		# Not actually setting add_screens
		if new_value:
			for i: int in range(0, 16):
				for j: int in range(0, 16):
					var new_screen: Screen = Screen.new()

					new_screen.global_position = Vector2i(i * 320, j * 180)
					var str_i: String = str(i)
					if str_i.length() == 1:
						str_i = "0" + str_i
					var str_j: String = str(j)
					if str_j.length() == 1:
						str_j = "0" + str_j

					new_screen.name = "Screen_" + str_i + "_" + str_j
					add_child(new_screen)
					new_screen.owner = self

@export var add_respawn_points: bool = false:
	set(new_value):
		# Not actually setting add_respawn_points
		if new_value:
			var screens: Array = find_children("*", "Screen")
			for screen: Screen in screens:
				var respawn_point: Marker2D = Marker2D.new()
				screen.add_child(respawn_point)
				respawn_point.owner = self
				respawn_point.name = "RespawnPoint"
				screen.respawn_point = respawn_point
				respawn_point.position = Vector2i(160, 90)


func _draw() -> void:
	for i: int in range(-16, 16):
		for j: int in range(-16, 16):
			var screen_bounds_rect: Rect2 = Rect2(i * 320, j * 180, 320, 180)
			draw_rect(screen_bounds_rect, Color.RED, false, 1.0)
