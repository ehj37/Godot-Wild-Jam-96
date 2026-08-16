extends CharacterBody2D

const _BASE_MOVE_SPEED: float = 50.0
const _CHARGE_MOVE_SPEED: float = _BASE_MOVE_SPEED * 2.0
const _GRAVITY: float = 600.0
const _CHARGE_MOVEMENT_INPUT_INFLUENCE: float = 0.5

var _charging: bool = false
var _pressed_movement_inputs: Array[String]

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _legs_down: PlayerLegs = $LegsDown
@onready var _legs_up: PlayerLegs = $LegsUp
@onready var _legs_left: PlayerLegs = $LegsLeft
@onready var _legs_right: PlayerLegs = $LegsRight
@onready var _all_legs: Array[PlayerLegs] = [_legs_down, _legs_up, _legs_left, _legs_right]


func _physics_process(delta: float) -> void:
	var has_overlapping_down: bool = _legs_down.on_surface()

	if Input.is_action_just_pressed("charge"):
		if _charging:
			_charging = false
			_set_legs_to_idle(_all_legs)
		else:
			_animation_player.play("charge")
			_charging = true

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
		# var has_overlapping_left: bool = _legs_left.on_surface()
		var has_overlapping_right: bool = _legs_right.on_surface()
		var has_overlapping_up: bool = _legs_up.on_surface()

		# TODO: Account for facing left vs. right at start of charge.
		# Consider orientation implementation. Locked by charge.

		var charge_direction: Vector2
		var charging_legs: PlayerLegs
		# NOTE: Logic is for bottom, right, and top legs.
		if has_overlapping_down && !has_overlapping_right:
			charge_direction = Vector2.RIGHT
			charging_legs = _legs_down
		elif has_overlapping_right && !has_overlapping_up:
			charge_direction = Vector2.UP
			charging_legs = _legs_right
		elif has_overlapping_up:
			charge_direction = Vector2.LEFT
			charging_legs = _legs_up

		if charging_legs:
			_set_legs_to_idle(
				_all_legs.filter(func(l: PlayerLegs) -> bool: return l != charging_legs)
			)
			charging_legs.play_charge()
		else:
			# Churn the bottom legs if there aren't any others that can do anything.
			_set_legs_to_idle(_all_legs.filter(func(l: PlayerLegs) -> bool: return l != _legs_down))
			_legs_down.play_charge()

		if charge_direction.is_zero_approx():
			if !input_movement_direction.is_zero_approx():
				if input_movement_direction.x > 0:
					velocity.x = max(input_movement_direction.x * _BASE_MOVE_SPEED, velocity.x)
				else:
					velocity.x = min(input_movement_direction.x * _BASE_MOVE_SPEED, velocity.x)

			velocity.y += _GRAVITY * delta
		else:
			var move_direction: Vector2 = (
				(_CHARGE_MOVEMENT_INPUT_INFLUENCE * input_movement_direction + charge_direction)
				. normalized()
			)
			velocity = move_direction * _CHARGE_MOVE_SPEED

	else:
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

		if velocity.x != 0:
			_animation_player.play("run")
			_legs_down.play_run()
		else:
			_animation_player.play("idle")
			_legs_down.play_idle()

	move_and_slide()


func _set_legs_to_idle(legs_list: Array[PlayerLegs]) -> void:
	for legs: PlayerLegs in legs_list:
		legs.play_idle()
