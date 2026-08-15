class_name State

extends Node

signal transition_requested(from_name: String, to_name: String)


func request_transition(to_name: String) -> void:
	transition_requested.emit(self.name, to_name)


func physics_update(_delta: float) -> void:
	pass


func enter(_data: Dictionary = {}) -> void:
	pass


func exit() -> void:
	pass
