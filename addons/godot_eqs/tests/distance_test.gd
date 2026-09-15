@tool
class_name EQSDistanceTest extends EQSTest
 
@export var distance_to: EQSContext.Point = EQSContext.Point.context_actor

@export_category("Filter")
@export var min_distance := 1.0
@export var max_distance := 10.0

@export_category("Score")
@export var weight := 1.0
@export var curve_distance := 5.0
@export var curve: Curve = Curve.new()

  
func filter(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	var context_position = (
		context.actor if distance_to == EQSContext.Point.context_actor
		else context.target
	)

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
 

func score(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	var context_position = (
		context.actor if distance_to == EQSContext.Point.context_actor
		else context.target
	)

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue

		var distance := candidate.position.distance_to(context_position.global_position)

		var value := curve.sample(clampf(distance / curve_distance, 0.0, 1.0))

		candidate.score += value * weight

		candidate.score_results["distance"] = value
