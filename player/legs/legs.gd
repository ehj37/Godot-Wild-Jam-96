class_name PlayerLegs

extends CollisionPolygon2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var _ground_detection_area: Area2D = $GroundDetectionArea
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func play_idle() -> void:
	_animation_player.play("idle")


func play_run() -> void:
	_animation_player.play("run")


func play_charge() -> void:
	_animation_player.play("charge")


func on_surface() -> bool:
	var climbable_surfaces: Array = _ground_detection_area.get_overlapping_bodies().filter(
		_can_climb
	)
	return climbable_surfaces.size() > 0


func _can_climb(body: Node2D) -> bool:
	if body is OneWayPlatforms:
		var one_way_platforms: OneWayPlatforms = body
		var one_way_platforms_surface_normal: Vector2 = one_way_platforms.surface_normal()
		var surface_direction: Vector2 = _surface_direction()
		if one_way_platforms_surface_normal.is_equal_approx(-surface_direction):
			return false

	return true


func _surface_direction() -> Vector2:
	return Vector2.from_angle(rotation - PI / 2)
