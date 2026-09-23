@tool
@icon("../assets/icons/matrix.svg")
class_name EQSQuery extends EQS

@export_category("Debug")
var _candidate_material: ShaderMaterial = preload("../assets/debugger/candidate_material.tres")
@export var is_enabled := false:
	set(value):
		is_enabled = value

		if is_enabled:
			execute()
		else:
			_clear_debug()

@export var show_scores := true
@export var score_size := 1.0
@export var score_y_offset := 0.5
@export var clear_timeout := 3.0
var _clear_timeout_timer := 0.0

var children: Array[Node]


func _process(delta: float) -> void:
	_clear_timeout_timer += delta

	if _clear_timeout_timer >= clear_timeout:
		_clear_debug()
		_clear_timeout_timer = 0.0
		

func execute() -> EQSResult:
	_clear_timeout_timer = 0.0

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

	# if best == null:
	# 	return EQSResult.new(all_candidates)

	if is_enabled:
		_clear_unnecessary_debug(all_candidates)

		_display_result(all_candidates)

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


func _get_debug_node() -> Node:
	for child in get_children():
		if child.name == "Execution Debug":
			return child
	return null


func _clear_debug():
	var child := _get_debug_node()
	if child != null:
		child.queue_free()
	pass


func _clear_unnecessary_debug(candidates: Array[EQSCandidate]):
	var child := _get_debug_node()
	if child != null:
		for point in child.get_children():
			if point.get_meta("candidate_index") >= candidates.size():
				point.queue_free()


func _display_result(all_candidates: Array[EQSCandidate], winner: EQSCandidate = null):
	var debug: Node3D = _get_debug_node()
	
	if debug == null:
		debug = Node3D.new()
		debug.name = "Execution Debug"
		debug.top_level = true
		add_child(debug)
		# debug.owner = get_tree().edited_scene_root

	print(debug.name)

	for i in range(all_candidates.size()):
		_create_candidate_mesh(debug, i, all_candidates[i], winner)

		
func _create_candidate_mesh(parent: Node3D, index: int, candidate: EQSCandidate, winner: EQSCandidate = null) -> void:
	var mesh_instance: MeshInstance3D = null

	for child in parent.get_children():
		if child is MeshInstance3D:
			if child.get_meta("candidate_index") == index:
				mesh_instance = child

	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "Candidate {index}".format({"index": index})
		parent.add_child(mesh_instance)
		# mesh_instance.owner = get_tree().edited_scene_root
		mesh_instance.set_meta("candidate_index", index)

		var sphere := SphereMesh.new()
				
		sphere.radius = 0.2
		sphere.height = 0.4
		sphere.radial_segments = 8
		sphere.rings = 4
		
		mesh_instance.mesh = sphere
		mesh_instance.material_override = _candidate_material
		
	mesh_instance.global_position = candidate.position
	mesh_instance.set_instance_shader_parameter("Score", clampf(candidate.score, 0.0, 1.0))
	mesh_instance.set_instance_shader_parameter("Valid", candidate.valid)
	mesh_instance.set_instance_shader_parameter("Tested", candidate.tested)
	
	if show_scores:
		var score: Label3D
		
		if mesh_instance.get_child_count() > 0:
			score = mesh_instance.get_child(0) as Label3D
		else:
			score = Label3D.new()
			score.name = "Score {index}".format({"index": index})
			mesh_instance.add_child(score)
			# score.owner = get_tree().edited_scene_root
			score.billboard = BaseMaterial3D.BILLBOARD_ENABLED

		if candidate.tested:
			if not candidate.valid:
				if candidate.filtered_by != null:
					score.text = candidate.filtered_by.name
				else:
					score.text = "Filtered"
			else:
				if winner != null and winner == candidate:
					score.text = "%.2f ⭐" % candidate.score
				else:
					score.text = "%.2f" % candidate.score
		else:
			score.text = ""

		score.scale = Vector3(score_size, score_size, score_size)
		score.position.y = score_y_offset
	else:
		if mesh_instance.get_child_count() > 0:
			var score = mesh_instance.get_child(0) as Label3D
			score.text = ""
