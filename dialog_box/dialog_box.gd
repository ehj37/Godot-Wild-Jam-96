@tool

class_name DialogBox

extends HBoxContainer

signal finished

const _BASE_DURATION_PER_CHARACTER: float = 0.06
const _SPEED_MODE_MULTIPLIER: float = 4.0
const _TEXT_LABEL_PATH: String = "PanelContainer/MarginContainer/VBoxContainer/RichTextLabel"

@export_multiline var text: String:
	set(new_value):
		text = new_value
		if Engine.is_editor_hint() && is_node_ready():
			var text_label: RichTextLabel = get_node(_TEXT_LABEL_PATH)
			text_label.text = text

var is_terminal: bool = true:
	set(new_value):
		is_terminal = new_value
		_set_bottom_right_label()
var _is_running: bool = false
var _in_speed_mode: bool = false
var _bottom_right_label: RichTextLabel
var _parsed_text_length: int

@onready var _text_label: RichTextLabel = get_node(_TEXT_LABEL_PATH)
@onready var _continue_label: RichTextLabel = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/ContinueLabel"
)
@onready var _finish_label: RichTextLabel = get_node(
	"PanelContainer/MarginContainer/VBoxContainer/FinishLabel"
)


func is_finished() -> bool:
	return _text_label.visible_ratio >= 1.0


func start() -> void:
	_is_running = true


func reset() -> void:
	_bottom_right_label.modulate.a = 0.0
	_text_label.visible_ratio = 0.0
	_in_speed_mode = false
	_is_running = false


func speed_up() -> void:
	_in_speed_mode = true


func slow_down() -> void:
	_in_speed_mode = false


func _process(delta: float) -> void:
	if Engine.is_editor_hint() || !_is_running:
		return

	var duration_per_character: float
	if _in_speed_mode:
		duration_per_character = _BASE_DURATION_PER_CHARACTER / _SPEED_MODE_MULTIPLIER
	else:
		duration_per_character = _BASE_DURATION_PER_CHARACTER
	_text_label.visible_ratio += delta / (duration_per_character * _parsed_text_length)

	if _text_label.visible_ratio >= 1.0:
		_bottom_right_label.modulate.a = 1.0
		_is_running = false
		finished.emit()


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	_text_label.text = text
	_parsed_text_length = _text_label.get_parsed_text().length()
	_set_bottom_right_label()
	_bottom_right_label.modulate.a = 0.0
	_text_label.visible_ratio = 0.0


func _set_bottom_right_label() -> void:
	if is_terminal:
		_continue_label.visible = false
		_finish_label.visible = true
		_bottom_right_label = _finish_label
	else:
		_finish_label.visible = false
		_continue_label.visible = true
		_bottom_right_label = _continue_label
