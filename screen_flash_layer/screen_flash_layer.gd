extends CanvasLayer

const _FLASH_DURATION: float = 0.5

var _alpha_tween: Tween

@onready var _color_rect: ColorRect = $ColorRect


func flash() -> void:
	if is_instance_valid(_alpha_tween):
		_alpha_tween.kill()

	_color_rect.color.a = 0.8

	_alpha_tween = create_tween()
	(
		_alpha_tween
		. tween_property(_color_rect, "color:a", 0.0, _FLASH_DURATION)
		. set_ease(Tween.EASE_OUT)
		. set_trans(Tween.TRANS_CUBIC)
	)


func _ready() -> void:
	_color_rect.color.a = 0.0
