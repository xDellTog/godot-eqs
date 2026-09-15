@tool
class_name EQSAngleTest extends EQSTest

@export_category("Score")
@export_range(-180.0, 180.0) var desired_angle := 0.0
@export var weight := 1.0
 

func score(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	if context.target == null:
		return
 
	var actor := context.actor
	var forward := -actor.global_basis.z
	var right := actor.global_basis.x

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue

		var direction := (candidate.position - actor.global_position).normalized()

		var angle := atan2(right.dot(direction), forward.dot(direction))

		var desired := deg_to_rad(desired_angle)

		var difference := absf(angle_difference(angle, desired))

		var value := 1.0 - (difference / PI)

		candidate.score += value * weight

		candidate.score_results["angle"] = value