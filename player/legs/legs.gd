class_name PlayerLegs

extends CollisionPolygon2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var _ground_detection_area: Area2D = $GroundDetectionArea
@onready var _moving_platform_detection_area: Area2D = $MovingPlatformDetectionArea
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func play_idle() -> void:
	_animation_player.play("idle")


func play_run() -> void:
	_animation_player.play("run")


func play_charge() -> void:
	_animation_player.play("charge")


func on_surface() -> bool:
	if _ground_detection_area.has_overlapping_bodies():
		return true

	var climbable_moving_platforms: Array = (
		_moving_platform_detection_area.get_overlapping_bodies().filter(_can_climb_moving_platform)
	)
	return climbable_moving_platforms.size() > 0


func _can_climb_moving_platform(body: Node2D) -> bool:
	var moving_platform_surface_normal: Vector2 = Vector2.from_angle(body.rotation - (PI / 2))
	var surface_direction: Vector2 = get_surface_direction()
	return moving_platform_surface_normal.is_equal_approx(surface_direction)


func get_surface_direction() -> Vector2:
	return Vector2.from_angle(rotation - PI / 2)
