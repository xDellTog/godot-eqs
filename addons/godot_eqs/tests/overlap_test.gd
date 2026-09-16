@tool
class_name EQSOverlapTest extends EQSTest


@export_category("Filter")
@export var extent := Vector3(1.0, 1.0, 1.0)
@export_flags_3d_physics var collision_layers := 1
@export var bool_match := false


func filter(candidates: Array[EQSCandidate], context: EQSContext) -> void:
	var space_state := context.actor.get_world_3d().direct_space_state

	for candidate in candidates:
		candidate.tested = true
		
		if not candidate.valid:
			continue

		var shape := BoxShape3D.new()
		shape.size = extent * 2.0

		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = shape
		query.transform = Transform3D(Basis.IDENTITY, candidate.position)
		query.collision_mask = collision_layers
		query.collide_with_bodies = true
		query.collide_with_areas = false

		var results := space_state.intersect_shape(query, 1)

		var is_overlap = results.is_empty()

		if bool_match:
			is_overlap = !is_overlap

		candidate.test_results["is_overlap"] = is_overlap
		
		if not is_overlap:
			candidate.valid = false
			candidate.filtered_by = self
			continue