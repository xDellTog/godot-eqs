@tool
class_name EQSDistanceFilter extends EQSFilter
 
@export var distance_to: EQSContext.Point = EQSContext.Point.context_actor

@export_category("Filter")
@export var min_distance := 1.0
@export var max_distance := 10.0

func filter(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	var context_position = (
		context.actor if distance_to == EQSContext.Point.context_actor
		else context.target
	)

	if context_position == null:
		push_error("Context points are null.")
		return

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue
			
		var distance := candidate.position.distance_to(context_position.global_position)

		var passed := distance >= min_distance and distance <= max_distance
		
		candidate.test_results["passed"] = passed
		
		if not passed:
			candidate.valid = false
			candidate.filtered_by = self
			continue
