@tool

extends Path2D

# Describes what happens when the progress ratio hits 0.0 or 1.0
enum MovementMode { BACK_AND_FORTH, STICKY }

const _SPEED: float = 30.0

@export var movement_mode: MovementMode = MovementMode.BACK_AND_FORTH
@export var is_moving: bool = true
@export var making_positive_progress: bool = true
@export var platform_rotation: int = 0:
	set(new_value):
		platform_rotation = wrapi(new_value, 0, 360)
		var remote_transform: RemoteTransform2D = $PathFollow2D/RemoteTransform2D
		remote_transform.rotation_degrees = platform_rotation

@export_range(0, 1.0) var initial_progress_ratio: float = 0.0:
	set(new_value):
		initial_progress_ratio = new_value
		if Engine.is_editor_hint():
			var path_follow: PathFollow2D = $PathFollow2D
			path_follow.progress_ratio = initial_progress_ratio

var _progress_ratio_speed: float

@onready var _rotate_audio_stream: AudioStreamOggVorbis = preload("./sound_effects/rotate.ogg")
@onready var _direction_change_audio_stream: AudioStreamOggVorbis = preload(
	"./sound_effects/direction_change.ogg"
)
@onready var _path_follow: PathFollow2D = $PathFollow2D
# Initial values for reset
@onready var _initial_is_moving: bool = is_moving
@onready var _initial_making_positive_progress: bool = making_positive_progress
@onready var _initial_platform_rotation: int = platform_rotation
@onready var _initial_progress_ratio: float = initial_progress_ratio


func reset() -> void:
	is_moving = _initial_is_moving
	making_positive_progress = _initial_making_positive_progress
	platform_rotation = _initial_platform_rotation
	_path_follow.progress_ratio = _initial_progress_ratio


func stop() -> void:
	is_moving = false


func start() -> void:
	is_moving = true


func flip_direction() -> void:
	_play_direction_changed_sound_effect()
	making_positive_progress = !making_positive_progress


func rotate_cw() -> void:
	SoundEffectManager.add_self_freeing_audio_stream_player(self, _rotate_audio_stream)

	platform_rotation += 90


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if !curve:
		if is_moving:
			push_warning(
				(
					"Moving platform at "
					+ str(global_position)
					+ " has is_moving as true, but has no curve."
				)
			)

		return

	if !is_moving:
		return

	var progress_ratio_update: float = _progress_ratio_speed * delta
	if !making_positive_progress:
		progress_ratio_update = -progress_ratio_update

	var updated_progress_ratio: float = _path_follow.progress_ratio + progress_ratio_update

	if movement_mode == MovementMode.BACK_AND_FORTH:
		# Flip direction
		if making_positive_progress && updated_progress_ratio > 1.0:
			_play_direction_changed_sound_effect()
			making_positive_progress = false
			updated_progress_ratio = 1.0 - fmod(updated_progress_ratio, 1.0)
		elif !making_positive_progress && updated_progress_ratio < 0.0:
			_play_direction_changed_sound_effect()
			making_positive_progress = true
			updated_progress_ratio = -fmod(updated_progress_ratio, 1.0)
	elif movement_mode == MovementMode.STICKY:
		if making_positive_progress:
			updated_progress_ratio = min(updated_progress_ratio, 1.0)
		else:
			updated_progress_ratio = max(updated_progress_ratio, 0.0)

	_path_follow.progress_ratio = updated_progress_ratio


func _ready() -> void:
	if curve:
		var curve_length: float = curve.get_baked_length()
		_progress_ratio_speed = _SPEED / curve_length
		_path_follow.progress_ratio = initial_progress_ratio


func _play_direction_changed_sound_effect() -> void:
	SoundEffectManager.add_self_freeing_audio_stream_player(self, _direction_change_audio_stream)
