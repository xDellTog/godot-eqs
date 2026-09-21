@tool
class_name WasHit
extends ConditionLeaf


func tick(_actor: Node, blackboard: Blackboard) -> int:
	return SUCCESS if blackboard.get_value("was_hit", false) else FAILURE