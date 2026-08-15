extends CharacterBody2D

var _charge: bool = false

@onready var _color_rect: ColorRect = $ColorRect
@onready var _ground_detection_area_down: Area2D = $GroundDetectionAreaDown
@onready var _ground_detection_area_right: Area2D = $GroundDetectionAreaRight
@onready var _ground_detection_area_up: Area2D = $GroundDetectionAreaUp
@onready var _ground_detection_area_left: Area2D = $GroundDetectionAreaLeft


func _physics_process(delta: float) -> void:
	var base_speed: float = 50.0
	var speed_mult: float

	if Input.is_action_just_pressed("speed_toggle"):
		_charge = !_charge

	if _charge:
		speed_mult = 2.0
		_color_rect.color = Color.RED
	else:
		speed_mult = 1.0
		_color_rect.color = Color.WHITE

	if _charge:
		if (
			_ground_detection_area_down.has_overlapping_bodies()
			&& !_ground_detection_area_right.has_overlapping_bodies()
		):
			velocity = Vector2.RIGHT * base_speed * speed_mult
		elif (
			_ground_detection_area_right.has_overlapping_bodies()
			&& !_ground_detection_area_up.has_overlapping_bodies()
		):
			velocity = Vector2.UP * base_speed * speed_mult
		elif (
			_ground_detection_area_up.has_overlapping_bodies()
			&& !_ground_detection_area_left.has_overlapping_bodies()
		):
			velocity = Vector2.LEFT * base_speed * speed_mult
		elif _ground_detection_area_left.has_overlapping_bodies():
			_charge = false
		else:
			# Hack-y test for cresting a corner
			velocity.x = base_speed * speed_mult
			# Add gravity
			velocity.y += 800.0 * delta
	else:
		if Input.is_action_pressed("move_right"):
			velocity = Vector2.RIGHT * base_speed * speed_mult
		elif Input.is_action_pressed("move_left"):
			velocity = Vector2.LEFT * base_speed * speed_mult
		else:
			if _ground_detection_area_down.has_overlapping_bodies():
				velocity = Vector2.ZERO
			else:
				velocity += Vector2.DOWN * 800.0 * delta

	move_and_slide()
