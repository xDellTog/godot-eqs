@tool
@icon("../assets/icons/bug.svg")
class_name EQSDebugger extends EQS

var _candidate_material: ShaderMaterial = preload("../assets/debugger/candidate_material.tres")

@export var is_enabled := false:
	set(value):
		is_enabled = value

		if is_enabled:
			execute_debug()
		else:
			_clear_debug()

@export var execute_in_editor := true

@export_range(0.01, 600.0, 0.01)
var update_interval := 0.25
var _timer := 0.0

@export var show_scores := true
 
@export_category("EQSQuery")
@export var query: EQSQuery

@export_category("EQSContext")
@export var actor: Node3D
@export var target: Node3D
 

func _process(delta: float) -> void:
	if not is_enabled:
		return
	
	if Engine.is_editor_hint() and not execute_in_editor:
		return

	if query == null:
		return

	_timer += delta

	if _timer < update_interval:
		return

	_timer = 0.0
 
	execute_debug()


func execute_debug():
	var context := _create_context()

	if query:
		var result := query.execute(context)

		_clear_unnecessary_debug(result.candidates)

		_display_result(result)


func _clear_debug():
	for child in get_children():
		child.queue_free()

func _clear_unnecessary_debug(candidates: Array[EQSCandidate]):
	for child in get_children():
		if child is MeshInstance3D:
			if child.get_meta("candidate_index") >= candidates.size():
				child.queue_free()

func _create_context() -> EQSContext:
	var context = EQSContext.new()
	context.actor = actor
	context.target = target
	return context


func _display_result(result: EQSResult):
	for i in range(result.candidates.size()):
		_create_candidate_mesh(i, result.candidates[i], result.winner)
 
func _create_candidate_mesh(index: int, candidate: EQSCandidate, winner: EQSCandidate) -> void:
	var mesh_instance: MeshInstance3D = null

	for child in get_children():
		if child is MeshInstance3D:
			if child.get_meta("candidate_index") == index:
				mesh_instance = child

	if mesh_instance == null:
		mesh_instance = MeshInstance3D.new()
		mesh_instance.name = "Candidate {index}".format({"index": index})
		add_child(mesh_instance)
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
				score.text = candidate.filtered_by.name
			else:
				if candidate == winner:
					score.text = "%.2f ⭐" % candidate.score
				else:
					score.text = "%.2f" % candidate.score
		else:
			score.text = ""

		score.scale = Vector3(.5, .5, .5)
		score.position.y = .3
	else:
		if mesh_instance.get_child_count() > 0:
			var score = mesh_instance.get_child(0) as Label3D
			score.text = ""
