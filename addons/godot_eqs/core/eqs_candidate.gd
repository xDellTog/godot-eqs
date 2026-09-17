class_name EQSCandidate extends RefCounted

## The candidate global position.
var position: Vector3
var valid := true
var score := 0.0

var tested := false
var filtered_by: EQSFilter

var test_results := {}
var score_results := {}

func _init(_position: Vector3) -> void:
	self.position = _position