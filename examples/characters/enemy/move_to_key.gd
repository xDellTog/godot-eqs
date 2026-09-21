@tool
class_name MoveToKey
extends ActionLeaf


@export var position_key: StringName = &"attack_pos"
@export var tolerance := 1.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	if not blackboard.has_value(position_key):
		return FAILURE
 
	var pos: Vector3 = blackboard.get_value(position_key) as Vector3

	return SUCCESS if actor.move_to_point(pos, tolerance) else RUNNING
