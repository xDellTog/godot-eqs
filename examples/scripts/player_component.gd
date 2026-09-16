extends Node

@export var manny: Manny
@export var camera: Camera3D

@export var camera_offset: Vector3

const RAY_LENGTH = 1000.0
const CAMERA_SPEED = 2.0
 
func _physics_process(delta: float) -> void:
	camera.global_position = camera.global_position.lerp(manny.global_position + camera_offset, delta * CAMERA_SPEED)
 
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
				manny.set_target_position(target_position)
		
		if event.button_index == MOUSE_BUTTON_LEFT:
			var result := space_state.intersect_ray(query)
			if result:
				if result.collider is CharacterBody3D:
					manny = result.collider as Manny
