class_name EQSResult extends RefCounted

var candidates: Array[EQSCandidate] = []
var winner: EQSCandidate
var success := false

func _init(_candidates: Array[EQSCandidate] = [], _winner: EQSCandidate = null):
	self.candidates = _candidates
	self.winner = _winner
	self.success = _winner != null
