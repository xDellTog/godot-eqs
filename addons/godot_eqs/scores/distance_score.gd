@tool
class_name EQSDistanceScore extends EQSScore
 
@export var weight := 1.0
@export var distance_to: EQSContext.Point = EQSContext.Point.context_actor
@export var curve_distance := 5.0
@export var curve: Curve = Curve.new()

func score(candidates: Array[EQSCandidate], context: EQSContext) -> void:
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

		var value := curve.sample(clampf(distance / curve_distance, 0.0, 1.0))

		candidate.score += value * weight

		candidate.score_results["distance"] = value