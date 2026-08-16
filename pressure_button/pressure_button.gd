extends Node2D

signal pressed
signal released

@onready var _sprite: Sprite2D = $Sprite2D


func _on_player_detection_area_body_entered(_body: Node2D) -> void:
	_set_sprite_to_pressed()
	pressed.emit()


func _on_player_detection_area_body_exited(_body: Node2D) -> void:
	_set_sprite_to_unpressed()
	released.emit()


func _set_sprite_to_pressed() -> void:
	_sprite.region_rect.position.x = 8


func _set_sprite_to_unpressed() -> void:
	_sprite.region_rect.position.x = 0
