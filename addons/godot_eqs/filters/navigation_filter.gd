@tool
class_name EQSNavigationFilter extends EQSFilter
 
@export var min_reachable_distance := 1.0
@export var max_path_length := 100.0

func filter(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	if context.actor == null:
		push_error("Context points are null.")
		return
		
	var map := context.actor.get_world_3d().navigation_map

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue

		var path := NavigationServer3D.map_get_path(map, context.actor.global_position, candidate.position, true)
		
		if path.is_empty():
			candidate.valid = false
			candidate.filtered_by = self
			candidate.test_results["navigation"] = false
			continue

		var final_point = path[-1]

		var reachable = final_point.distance_to(candidate.position) <= min_reachable_distance

		if not reachable:
			candidate.valid = false
			candidate.filtered_by = self
			candidate.test_results["navigation"] = false
			continue

		var path_length := _calculate_path_length(path)

		if path_length > max_path_length:
			candidate.valid = false
			candidate.filtered_by = self

		candidate.test_results["navigation"] = {
			"valid": candidate.valid,
			"path_length": path_length
		}


func _calculate_path_length(path: PackedVector3Array) -> float:
	var length := 0.0

	for i in range(1, path.size()):
		length += path[i - 1].distance_to(path[i])

	return length
