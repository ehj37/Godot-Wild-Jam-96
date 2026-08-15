class_name StateMachine

extends Node

@export var initial_state: State

var _states: Array[State]
var _current_state: State


func _physics_process(delta: float) -> void:
	_current_state.physics_update(delta)


func _ready() -> void:
	for state: State in get_children():
		_states.append(state)

	_current_state = initial_state
	initial_state.enter()
