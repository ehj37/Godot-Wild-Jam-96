extends PointLight2D


func _process(_delta: float) -> void:
	rotation = randf_range(0, 2 * PI)
