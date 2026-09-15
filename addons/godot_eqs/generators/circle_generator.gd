@tool
class_name EQSCircleGenerator extends EQSGenerator
 
@export var radius: float = 5.0
@export_range(4, 64) var points: int = 16
@export var height: float = 0.0

func generate(context: EQSContext) -> Array[EQSCandidate]:
    var result: Array[EQSCandidate] = []

    for i in points:
        var angle := TAU * float(i) / points

        var point := context.actor.global_position + Vector3(cos(angle) * radius, height, sin(angle) * radius)

        var projected = project_to_navigation(point, context)

        if projected != null:
            projected.y = projected.y + height
            result.append(EQSCandidate.new(projected)) 

    return result