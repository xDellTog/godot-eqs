@tool
@icon("../assets/icons/brick_wall.svg")
class_name EQSGenerator extends EQS

@export var is_enabled := true
 
@export var use_nav_projection := true

@export var projection_up := 2.0
@export var projection_down := 2.0
@export var max_horizontal_distance := 0.5
@export var use_fallback := true
@export var max_fallback_distance := 2.0

@export_flags_3d_physics var projection_collision_mask := 1

func generate(_context: EQSContext) -> Array[EQSCandidate]:
	return []


func project_to_navigation(point: Vector3, context: EQSContext, ) -> Variant:
	var world := context.actor.get_world_3d()
	
	if not world:
		return null
		
	var map := world.navigation_map

	if not map.is_valid():
		return null

	var vertical_point = _project_vertical(point, context, map)

	if vertical_point != null:
		return vertical_point
 
	if not use_fallback:
		return null

	var closest := NavigationServer3D.map_get_closest_point(map, point)

	if closest.distance_to(point) > max_fallback_distance:
		return null

	return closest


func _project_vertical(point: Vector3, context: EQSContext, map: RID) -> Variant:
	var space_state := context.actor.get_world_3d().direct_space_state

	var from := point + Vector3.UP * projection_up
	var to := point + Vector3.DOWN * projection_down

	var query := PhysicsRayQueryParameters3D.create(from, to)

	query.collision_mask = projection_collision_mask
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var hit := space_state.intersect_ray(query)

	if hit.is_empty():
		return null

	var surface_point: Vector3 = hit.position

	var nav_point := NavigationServer3D.map_get_closest_point(map, surface_point)

	var horizontal_distance := Vector2(nav_point.x - point.x, nav_point.z - point.z).length()

	if horizontal_distance > max_horizontal_distance:
		return null

	return nav_point
