@tool
@icon("../assets/icons/scoreboard.svg")
class_name EQSTest extends EQS

enum EQSTestType {filter_and_score, filter, score}

@export var is_enabled := true
@export var type := EQSTestType.filter_and_score

func filter(_candidates: Array[EQSCandidate], _context: EQSContext) -> void:
    pass

func score(_candidates: Array[EQSCandidate], _context: EQSContext) -> void:
    pass