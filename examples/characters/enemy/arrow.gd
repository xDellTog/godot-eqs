class_name Arrow extends RayCast3D

@export var speed := 15.0
@export var source: CharacterBody3D

func _process(delta: float) -> void:
	position += global_basis * Vector3.FORWARD * speed * delta

	if is_colliding():
		var body = get_collider() as Node3D

		if body.is_in_group('Player'):
			var player := body as Player
			player.take_damage(10)
			player.apply_impulse(Vector3.UP * 2.0)

		if body.is_in_group('Enemy'):
			var enemy := body as Enemy
			enemy.take_damage(10, source)
			enemy.apply_impulse(Vector3.UP * 2.0)
				
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()
