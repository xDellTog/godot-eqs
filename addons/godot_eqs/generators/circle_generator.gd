@tool
class_name EQSCircleGenerator extends EQSGenerator
 
@export var radius: float = 5.0
@export_range(4, 64) var points: int = 16
@export var post_projection_vertical_offset: float = 0.0
@export var use_actor_rotation := true

func generate(context: EQSContext) -> Array[EQSCandidate]:
	var result: Array[EQSCandidate] = []

	for i in points:
		var angle := TAU * float(i) / points

		var point: Vector3
		if use_actor_rotation:
			point = context.actor.global_transform * Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		else:
			point = context.actor.global_position + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)

		var projected = project_to_navigation(point, context)

		if projected != null:
			projected.y = projected.y + post_projection_vertical_offset
			result.append(EQSCandidate.new(projected))

	return result