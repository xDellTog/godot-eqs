extends Node

func _on_manny_2_finish_locomotion() -> void:
	var manny: Manny = get_parent() as Manny
	if manny.eqs_query != null:
		var player := manny.eqs_query.get_context().actor as CharacterBody3D
		var tween = manny.create_tween().set_parallel()
		var direction := player.global_position.direction_to(manny.global_position)
		var angle := manny.rotation.y + angle_difference(manny.rotation.y, atan2(direction.x, direction.z))
		tween.tween_property(manny, "rotation:y", angle, .25)
	pass
