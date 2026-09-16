@tool
@icon("../assets/icons/test_tube.svg")
class_name EQSFilter extends EQS

@export var is_enabled := true

func filter(_candidates: Array[EQSCandidate], _context: EQSContext) -> void:
    pass