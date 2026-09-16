@tool
class_name EQSRandomScore extends EQSScore

@export var weight := 1.0

func score(candidates: Array[EQSCandidate], _context: EQSContext) -> void:
	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue

		var value := randf()

		candidate.score += value * weight

		candidate.score_results["random"] = value