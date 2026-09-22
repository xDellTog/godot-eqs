@tool
class_name AcquireTarget
extends ConditionLeaf


func tick(actor: Node, blackboard: Blackboard) -> int:
	var target = blackboard.get_value("target")
	if is_instance_valid(target):
		return SUCCESS
 
	var player := actor.get_tree().get_first_node_in_group("Player") as Node3D
	if player and actor.can_see(player):
		blackboard.set_value("target", player)
		return SUCCESS

	return FAILURE