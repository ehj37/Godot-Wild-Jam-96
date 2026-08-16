extends CharacterBody2D

enum LegState { NONE, DOWN, DOWN_RIGHT, DOWN_RIGHT_UP, DOWN_RIGHT_UP_LEFT }

const _BASE_MOVE_SPEED: float = 50.0
const _CHARGE_MOVE_SPEED: float = _BASE_MOVE_SPEED * 2.0
const _GRAVITY: float = 600.0
const _CHARGE_MOVEMENT_INPUT_INFLUENCE: float = 0.5

@export var leg_state: LegState:
	set(new_value):
		leg_state = new_value
		_update_legs()

var _flipped: bool = false
var _charging: bool = false
var _pressed_movement_inputs: Array[String]

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _legs_down: PlayerLegs = $LegsDown
@onready var _legs_up: PlayerLegs = $LegsUp
@onready var _legs_left: PlayerLegs = $LegsLeft
@onready var _legs_right: PlayerLegs = $LegsRight
@onready var _all_legs: Array[PlayerLegs] = [_legs_down, _legs_right, _legs_up, _legs_left]


func _physics_process(delta: float) -> void:
	var has_overlapping_down: bool = _legs_down.on_surface()

	if Input.is_action_just_pressed("charge") && leg_state != LegState.NONE:
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
		var owned_legs: Array[PlayerLegs] = _all_legs.slice(0, leg_state)
		var charge_direction: Vector2
		var charging_legs: PlayerLegs
		var total_legs_count: int = _all_legs.size()
		for candidate_legs_i: int in total_legs_count:
			var candidate_legs: PlayerLegs = _all_legs[candidate_legs_i]
			if !owned_legs.has(candidate_legs):
				break

			var next_legs: PlayerLegs
			if _flipped:
				next_legs = _all_legs[wrapi(candidate_legs_i - 1, 0, total_legs_count)]
			else:
				next_legs = _all_legs[(candidate_legs_i + 1) % total_legs_count]

			if owned_legs.has(next_legs) && next_legs.on_surface():
				continue

			if candidate_legs.on_surface():
				charging_legs = candidate_legs
				charge_direction = Vector2.from_angle(charging_legs.rotation)
				if _flipped:
					charge_direction = -charge_direction

				break

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
			if !input_movement_direction.is_zero_approx():
				_update_flipped(input_movement_direction.x < 0.0)
		else:
			if !input_movement_direction.is_zero_approx():
				# Could be moving in the same direction as the charge was, but
				# _BASE_MOVE_SPEED is slower than _CHARGE_MOVE_SPEED, so we shouldn't
				# overwrite in that case.
				if input_movement_direction.x > 0:
					_update_flipped(false)
					velocity.x = max(input_movement_direction.x * _BASE_MOVE_SPEED, velocity.x)
				else:
					_update_flipped(true)
					velocity.x = min(input_movement_direction.x * _BASE_MOVE_SPEED, velocity.x)
			velocity.y += _GRAVITY * delta

		if velocity.x != 0:
			_animation_player.play("run")
			_legs_down.play_run()
		else:
			_animation_player.play("idle")
			_legs_down.play_idle()

	move_and_slide()


func _ready() -> void:
	_update_legs()


func _set_legs_to_idle(legs_list: Array[PlayerLegs]) -> void:
	for legs: PlayerLegs in legs_list:
		legs.play_idle()


# TODO: Just use a setter instead?
func _update_flipped(value: bool) -> void:
	if value == _flipped:
		return

	_flipped = value
	_sprite.flip_h = _flipped
	for legs: PlayerLegs in _all_legs:
		legs.sprite.flip_h = _flipped


func _update_legs() -> void:
	var owned_legs: Array[PlayerLegs] = _all_legs.slice(0, leg_state)
	var unowned_legs: Array[PlayerLegs] = _all_legs.filter(
		func(l: PlayerLegs) -> bool: return !owned_legs.has(l)
	)

	for legs: PlayerLegs in owned_legs:
		legs.visible = true
		legs.disabled = false

	for legs: PlayerLegs in unowned_legs:
		legs.visible = false
		legs.disabled = true
