@tool
class_name EQSLineOfSightFilter extends EQSFilter
 
@export var from: EQSContext.Point = EQSContext.Point.context_actor
@export var point_of_view_height := 1.0
@export_flags_3d_physics var collision_mask := 1
@export var bool_match := false

func filter(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	var context_from_position = (
		context.actor if from == EQSContext.Point.context_actor
		else context.target
	)

	var context_to_position = (
		context.target if from == EQSContext.Point.context_actor
		else context.actor
	)
 	
	if context_from_position == null or context_to_position == null:
		push_error("Context points are null.")
		return

	var space_state := context_from_position.get_world_3d().direct_space_state

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue
			
		var point_of_view = context_to_position.global_position + Vector3.UP * point_of_view_height
		var query := PhysicsRayQueryParameters3D.create(candidate.position, point_of_view, collision_mask)
		
		query.exclude = [context_from_position]

		var hit := space_state.intersect_ray(query)
		
		var has_los := hit.is_empty()
		
		if bool_match:
			has_los = !has_los

		candidate.test_results["line_of_sight"] = has_los

		if not has_los:
			candidate.valid = false
			candidate.filtered_by = self
			continue
