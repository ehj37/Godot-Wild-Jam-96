extends Path2D

const _SPEED: float = 30.0

var _making_positive_progress: bool = true
var _progress_ratio_speed: float

@onready var _path_follow: PathFollow2D = $PathFollow2D


func _physics_process(delta: float) -> void:
	if !curve:
		return

	var progress_ratio_update: float = _progress_ratio_speed * delta
	if !_making_positive_progress:
		progress_ratio_update = -progress_ratio_update

	var updated_progress_ratio: float = _path_follow.progress_ratio + progress_ratio_update
	# Flip direction
	if _making_positive_progress && updated_progress_ratio > 1.0:
		_making_positive_progress = false
		updated_progress_ratio = 1.0 - fmod(updated_progress_ratio, 1.0)
	elif !_making_positive_progress && updated_progress_ratio < 0.0:
		_making_positive_progress = true
		updated_progress_ratio = -fmod(updated_progress_ratio, 1.0)

	_path_follow.progress_ratio = updated_progress_ratio


func _ready() -> void:
	if curve:
		var curve_length: float = curve.get_baked_length()
		_progress_ratio_speed = _SPEED / curve_length
