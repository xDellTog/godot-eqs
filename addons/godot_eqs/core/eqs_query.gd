@tool
@icon("../assets/icons/matrix.svg")
class_name EQSQuery extends EQS
 

func execute(context: EQSContext) -> EQSResult:
	var weight_sum := 0.0
	
	var generator := _get_generator()

	if generator == null:
		push_error("EQSQuery requires a generator.")
		return EQSResult.new()
 
	var candidates := generator.generate(context)
	
	if candidates.is_empty():
		return EQSResult.new()
 
	for test in get_children():
		if test is EQSTest:
			if test.is_enabled:
				if test.type == EQSTest.EQSTestType.filter or test.type == EQSTest.EQSTestType.both:
					test.filter(candidates, context)

				if test.type == EQSTest.EQSTestType.score or test.type == EQSTest.EQSTestType.both:
					test.score(candidates, context)
					weight_sum += test.weight
  
	var best: EQSCandidate = null

	for candidate in candidates:
		if not candidate.valid:
			continue

		candidate.score = candidate.score / weight_sum if weight_sum > 0 else 0.0

		if best == null or candidate.score > best.score:
			best = candidate

	if best == null:
		return EQSResult.new(candidates)

	return EQSResult.new(candidates, best)
 
func _get_generator() -> EQSGenerator:
	for generator in get_children():
		if generator is EQSGenerator:
			if generator.is_enabled:
				return generator

	return null