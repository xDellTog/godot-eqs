@tool
class_name EQSRandomGenerator
extends EQSGenerator

@export var radius := 10.0
@export var count := 20
@export var height: float = 0.0

func generate(context: EQSContext) -> Array[EQSCandidate]:
	var result: Array[EQSCandidate] = []

	for i in count:
		var angle := randf() * TAU
		var distance := sqrt(randf()) * radius

		var point := context.actor.global_position + Vector3(cos(angle) * distance, 0.0, sin(angle) * distance)

		var projected = project_to_navigation(point, context)

		if projected != null:
			projected.y = projected.y + height
			result.append(EQSCandidate.new(projected))

	return result