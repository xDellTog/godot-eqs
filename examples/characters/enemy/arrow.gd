extends RayCast3D

@export var speed := 15.0

func _process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta

	if is_colliding():
		var body = get_collider()
		if body.is_in_group('Player'):
			var player := body as Player
			print(player)
			# enemy.apply_damage(10)
		# if body.has_method('apply_impulse'):
		# 	body.apply_impulse(-basis.z * strength, get_collision_point() - body.global_position)
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
