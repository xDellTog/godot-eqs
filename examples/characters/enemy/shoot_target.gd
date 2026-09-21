@tool
class_name ShootTarget
extends ActionLeaf


@export var lose_sight_grace := 1.0

var _no_los_time := 0.0


func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	_no_los_time = 0.0


func tick(actor: Node, blackboard: Blackboard) -> int:
	var target = blackboard.get_value("target")
	if not is_instance_valid(target):
		return FAILURE

	actor.face_toward(target.global_position)

	if actor.can_see(target):
		_no_los_time = 0.0
		actor.try_shoot(target)
	else:
		_no_los_time += get_physics_process_delta_time()
		if _no_los_time >= lose_sight_grace:
			blackboard.erase_value("attack_pos")
			return FAILURE

	return RUNNING
