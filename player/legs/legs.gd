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
	return _ground_detection_area.has_overlapping_bodies()
