@tool
class_name EQSGridGenerator extends EQSGenerator

@export var size := 10.0
@export var spacing := 1.0
@export var post_projection_vertical_offset: float = 0.0
@export var use_actor_rotation := true

func generate(context: EQSContext) -> Array[EQSCandidate]:
	var result: Array[EQSCandidate] = []

	var half_x := size * 0.5
	var half_z := size * 0.5

	var x := -half_x

	while x <= half_x:
		var z := -half_z

		while z <= half_z:
			var point: Vector3
			if use_actor_rotation:
				point = context.actor.global_transform * Vector3(x, 0.0, z)
			else:
				point = context.actor.global_position + Vector3(x, 0.0, z)

			var projected = project_to_navigation(point, context)

			if projected != null:
				projected.y = projected.y + post_projection_vertical_offset
				result.append(EQSCandidate.new(projected))

			z += spacing

		x += spacing

	return result