@tool
class_name HideInCover
extends ActionLeaf

@export var hide_time_min := 2.5
@export var hide_time_max := 4.5

var _until_ms := 0


func before_run(_actor: Node, _blackboard: Blackboard) -> void:
	var secs := randf_range(hide_time_min, hide_time_max)
	_until_ms = Time.get_ticks_msec() + int(secs * 1000.0)


func tick(_actor: Node, blackboard: Blackboard) -> int:
	if Time.get_ticks_msec() < _until_ms:
		return RUNNING

	if blackboard.has_value("attack_pos"):
		blackboard.set_value("last_attack_pos", blackboard.get_value("attack_pos"))
		blackboard.erase_value("attack_pos")

	return SUCCESS