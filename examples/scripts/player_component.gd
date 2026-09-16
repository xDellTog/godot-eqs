extends Node

@export var player: Manny
@export var camera: Camera3D
@export var camera_offset: Vector3

const RAY_LENGTH = 1000.0
const CAMERA_SPEED = 3.0
 
func _physics_process(delta: float) -> void:
	var level = get_parent() as Node3D
	var camera_position = player.global_position
	var manny_in_scene = 1

	for child in level.get_children():
		if child is Manny and child != player:
			manny_in_scene += 1
			camera_position += child.global_position

	camera.global_position = camera.global_position.lerp(camera_position / manny_in_scene + camera_offset, delta * CAMERA_SPEED)
 
func _input(event):
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
			var result := space_state.intersect_ray(query)
			if result:
				if result.collider is Manny:
					player = result.collider as Manny
