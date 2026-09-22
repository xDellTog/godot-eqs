extends Node

@export var player: CharacterBody3D

@export var camera: Camera3D
@export var camera_offset: Vector3

const RAY_LENGTH = 1000.0
const CAMERA_SPEED = 3.0
 
func _physics_process(delta: float) -> void:
	handle_camera(delta)

func handle_camera(delta):
	var level = get_parent() as Node3D
	var characters = level.find_children("*", "CharacterBody3D")
	var camera_position = characters[0].global_position
	var manny_in_scene = 1

	if characters.size() > 1:
		for child in characters:
			if child is CharacterBody3D:
				camera_position += child.global_position
				manny_in_scene += 1

	camera.global_position = camera.global_position.lerp(camera_position / manny_in_scene + camera_offset, delta * CAMERA_SPEED)
 
func _input(event):
	if player:
		if event is InputEventMouseMotion:
			if not player.is_moving:
				var parent := get_parent() as Node3D
				var mouse_pos = event.position
				var space_state := parent.get_world_3d().direct_space_state
				
				var origin = camera.project_ray_origin(mouse_pos)
				var end = origin + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
				
				var query = PhysicsRayQueryParameters3D.create(origin, end)
				query.exclude = [player]
				var result := space_state.intersect_ray(query)
				if result:
					var intersect_point = result.position as Vector3
					var direction := intersect_point.direction_to(player.global_position)
					var angle := player.rotation.y + angle_difference(player.rotation.y, atan2(direction.x, direction.z))
					var tween = player.create_tween().set_parallel()
					tween.tween_property(player, "rotation:y", angle, .1)


		if event is InputEventMouseButton and event.pressed:
			var parent := get_parent() as Node3D
			var mouse_pos = event.position
			
			var space_state := parent.get_world_3d().direct_space_state
			
			var origin = camera.project_ray_origin(mouse_pos)
			var end = origin + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
			
			var query = PhysicsRayQueryParameters3D.create(origin, end)
			
			if event.button_index == MOUSE_BUTTON_RIGHT:
				var result := space_state.intersect_ray(query)
				if result:
					var target_position: Vector3 = result.position
					player.set_target_position(target_position)
			
			if event.button_index == MOUSE_BUTTON_LEFT:
				# var result := space_state.intersect_ray(query)
				# if result:
				# 	if result.collider is Enemy:
				# 		var enemy = result.collider as Enemy
				# 		player.try_shoot()
				player.try_shoot()
