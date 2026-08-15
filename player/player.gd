extends CharacterBody2D

const _BASE_MOVE_SPEED: float = 50.0
const _CHARGE_MOVE_SPEED: float = _BASE_MOVE_SPEED * 3.0
const _GRAVITY: float = 800.0
const _CHARGE_MOVEMENT_INPUT_INFLUENCE: float = 0.5

var _charging: bool = false
var _pressed_movement_inputs: Array[String]

@onready var _color_rect: ColorRect = $ColorRect
@onready var _ground_detection_area_down: Area2D = $GroundDetectionAreaDown
@onready var _ground_detection_area_right: Area2D = $GroundDetectionAreaRight
@onready var _ground_detection_area_up: Area2D = $GroundDetectionAreaUp
@onready var _ground_detection_area_left: Area2D = $GroundDetectionAreaLeft


func _physics_process(delta: float) -> void:
	var has_overlapping_down: bool = _ground_detection_area_down.has_overlapping_bodies()

	if Input.is_action_just_pressed("charge"):
		if _charging:
			_charging = false
		else:
			if has_overlapping_down:
				_charging = true
			else:
				# TODO: Play a sound to show that the input was recognized but
				# the charge wasn't allowed.
				pass

	var movement_inputs: Array = ["move_right", "move_left"]
	for movement_input: String in movement_inputs:
		if Input.is_action_just_pressed(movement_input):
			if !_pressed_movement_inputs.has(movement_input):
				_pressed_movement_inputs.append(movement_input)

		if !Input.is_action_pressed(movement_input):
			_pressed_movement_inputs.erase(movement_input)

	var input_movement_direction: Vector2 = Vector2.ZERO
	if _pressed_movement_inputs.size() > 0:
		var chosen_movement_input: String = _pressed_movement_inputs.back()
		if chosen_movement_input == "move_right":
			input_movement_direction = Vector2.RIGHT
		elif chosen_movement_input == "move_left":
			input_movement_direction = Vector2.LEFT
		else:
			push_error("Unhandled movement input.")

	if _charging:
		_color_rect.color = Color.RED

		var has_overlapping_left: bool = _ground_detection_area_left.has_overlapping_bodies()
		var has_overlapping_right: bool = _ground_detection_area_right.has_overlapping_bodies()
		var has_overlapping_up: bool = _ground_detection_area_up.has_overlapping_bodies()

		# TODO: Account for facing left vs. right at start of charge.
		# Consider orientation implementation. Locked by charge.

		var charge_direction: Vector2
		# NOTE: Logic is for bottom, right, and top legs.
		if has_overlapping_down && !has_overlapping_right:
			charge_direction = Vector2.RIGHT
		elif has_overlapping_right && !has_overlapping_up:
			charge_direction = Vector2.UP
		elif has_overlapping_up && !has_overlapping_left:
			charge_direction = Vector2.LEFT

		if charge_direction.is_zero_approx():
			if !input_movement_direction.is_zero_approx():
				velocity.x = input_movement_direction.x * _BASE_MOVE_SPEED

			velocity.y += _GRAVITY * delta
		else:
			var move_direction: Vector2 = (
				(_CHARGE_MOVEMENT_INPUT_INFLUENCE * input_movement_direction + charge_direction)
				. normalized()
			)
			velocity = move_direction * _CHARGE_MOVE_SPEED

	else:
		_color_rect.color = Color.WHITE
		if has_overlapping_down:
			velocity.x = input_movement_direction.x * _BASE_MOVE_SPEED
		else:
			if !input_movement_direction.is_zero_approx():
				# Could be moving in the same direction as the charge was, but
				# _BASE_MOVE_SPEED is slower than _CHARGE_MOVE_SPEED, so we shouldn't
				# overwrite in that case.
				if input_movement_direction.x > 0:
					velocity.x = max(input_movement_direction.x * _BASE_MOVE_SPEED, velocity.x)
				else:
					velocity.x = min(input_movement_direction.x * _BASE_MOVE_SPEED, velocity.x)
			velocity.y += _GRAVITY * delta

	move_and_slide()
