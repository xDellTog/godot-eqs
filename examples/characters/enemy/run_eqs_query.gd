@tool
class_name RunEqsQuery
extends ActionLeaf

@export var query: EQSQuery
@export var result_key: StringName = &"attack_pos"

@export var consume_was_hit := false


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if consume_was_hit:
		blackboard.set_value("was_hit", false)

	var target = blackboard.get_value("target")
	if not is_instance_valid(target):
		return FAILURE

	var result := query.execute()
	if result == null or result.winner == null:
		return FAILURE

	blackboard.set_value(result_key, result.winner.position)
	return SUCCESS