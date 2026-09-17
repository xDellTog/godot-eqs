@tool
class_name EQSAngleScore extends EQSScore
 
@export var weight := 1.0
@export var angle_to: EQSContext.Point = EQSContext.Point.context_actor
@export_range(-180.0, 180.0) var desired_angle := 0.0

func score(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	var context_point: Node3D = (
		context.actor if angle_to == EQSContext.Point.context_actor
		else context.target
	)

	if context_point == null:
		push_error("Context points are null.")
		return

	var forward := -context_point.global_basis.z
	var right := context_point.global_basis.x

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue

		var direction := (candidate.position - context_point.global_position).normalized()

		var angle := atan2(right.dot(direction), forward.dot(direction))

		var desired := deg_to_rad(desired_angle)

		var difference := absf(angle_difference(angle, desired))

		var value := 1.0 - (difference / PI)

		candidate.score += value * weight

		candidate.score_results["angle"] = value