extends CanvasLayer

@export var player: Player
@export var player_camera: Camera2D


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("open_debug_menu"):
		visible = !visible

	if Input.is_action_just_pressed("move_left") || Input.is_action_just_pressed("move_right"):
		visible = false


func _ready() -> void:
	visible = false


func _on_no_legs_button_pressed() -> void:
	player.leg_state = Player.LegState.NONE


func _on_d_button_pressed() -> void:
	player.leg_state = Player.LegState.DOWN


func _on_dr_button_pressed() -> void:
	player.leg_state = Player.LegState.DOWN_RIGHT


func _on_dru_button_pressed() -> void:
	player.leg_state = Player.LegState.DOWN_RIGHT_UP


func _on_drul_button_pressed() -> void:
	player.leg_state = Player.LegState.DOWN_RIGHT_UP_LEFT


func _on_camera_zoom_in_button_pressed() -> void:
	player_camera.zoom += Vector2.ONE


func _on_camera_zoom_out_button_pressed() -> void:
	player_camera.zoom -= Vector2.ONE
