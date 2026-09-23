@tool
@icon("../assets/icons/matrix.svg")
class_name EQSQuery extends EQS

var children: Array[Node]

func execute() -> EQSResult:
	children = get_children() as Array[Node]

	var context: EQSContext = get_context()
	if context == null:
		push_error("EQSQuery requires a context.")
		return EQSResult.new()


	var generator: EQSGenerator = get_generator()
	if generator == null:
		push_error("EQSQuery requires a generator.")
		return EQSResult.new()
	
	var all_candidates := generator.generate(context)
	if all_candidates.is_empty():
		return EQSResult.new()
	

	var active_candidates = all_candidates.duplicate()
  
	for filter in children:
		if filter is EQSFilter and filter.is_enabled:
			filter.filter(active_candidates, context)
			_compact(active_candidates)
				
	var weight_sum := 0.0
	for score in children:
		if score is EQSScore and score.is_enabled:
			score.score(active_candidates, context)
			weight_sum += score.weight
	
	
	var best: EQSCandidate = null
	for candidate in active_candidates:
		candidate.score = candidate.score / weight_sum if weight_sum > 0 else 0.0
		if best == null or candidate.score > best.score:
			best = candidate

	if best == null:
		return EQSResult.new(all_candidates)

	return EQSResult.new(all_candidates, best)


func _compact(candidates: Array) -> void:
	var i := 0
	while i < candidates.size():
		if not candidates[i].valid:
			var last := candidates.size() - 1
			candidates[i] = candidates[last]
			candidates.remove_at(last)
		else:
			i += 1


func get_context():
	for context in children:
		if context is EQSContext:
			return context
	
	return null


func get_generator():
	for generator in children:
		if generator is EQSGenerator and generator.is_enabled:
			return generator
	
	return null