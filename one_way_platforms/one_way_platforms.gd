class_name OneWayPlatforms

extends TileMapLayer


# Due to Godot TileMapLayer limitations with one way collisions and my lack of
# proficiency with them, a sideways one-way platform should be accomplished by
# rotating a one way platform tile map layer some multiple of 90 deg.
func surface_normal() -> Vector2:
	return Vector2.from_angle(rotation - (PI / 2))
