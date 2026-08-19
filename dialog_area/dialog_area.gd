class_name DialogArea

extends Area2D

signal dialog_finished

const _FADE_TWEEN_DURATION: float = 0.2

@export var dialog_boxes: Array[DialogBox]
@export var one_shot: bool = false
@export var disabled: bool = false

@onready var _interact_label: RichTextLabel = $InteractLabel


func on_start() -> void:
	monitoring = false


func on_finish() -> void:
	if !one_shot:
		monitoring = true

	dialog_finished.emit()


func display_interact_label() -> void:
	_interact_label.visible = true


func hide_interact_label() -> void:
	_interact_label.visible = false


func disable() -> void:
	monitoring = false


func enable() -> void:
	monitoring = true


func _ready() -> void:
	for i: int in dialog_boxes.size():
		var dialog_box: DialogBox = dialog_boxes[i]
		dialog_box.is_terminal = i == dialog_boxes.size() - 1
		dialog_box.visible = false

	_interact_label.visible = false
	if disabled:
		disable()


func _on_body_entered(_body: Node2D) -> void:
	DialogManager.register(self)


func _on_body_exited(_body: Node2D) -> void:
	DialogManager.unregister(self)
