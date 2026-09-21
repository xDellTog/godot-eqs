class_name EnemyQueries
extends RefCounted

static func run(query_name: StringName, actor: Node3D, target: Node3D, blackboard: Blackboard) -> Variant:
	match query_name:
		&"attack_position":
			return _attack_position(actor, target, blackboard)
		&"cover":
			return _cover(actor, target)
	push_error("EnemyQueries: query desconhecida '%s'" % query_name)
	return null


static func _attack_position(actor: Node3D, target: Node3D, blackboard: Blackboard) -> Variant:
	# TODO: ligar no addon de EQS. Query sugerida:
	#   Gerador : pontos em anel ao redor do ALVO (raio ~12 a 22 m)
	#   Filtros : ponto navegável
	#             linha de visão para o alvo
	#             distância até blackboard "last_attack_pos" > ~6 m  (garante "outra" posição)
	#   Scores  : preferir distância ao alvo perto de ~16 m
	#             preferir pontos mais próximos do inimigo (menos caminhada)
	# Retornar o melhor ponto (Vector3) ou null se nada passar nos filtros.
	var _last = blackboard.get_value("last_attack_pos")
	return null


static func _cover(actor: Node3D, threat: Node3D) -> Variant:
	# TODO: ligar no addon de EQS. Query sugerida:
	#   Gerador : pontos em volta do INIMIGO (raio ~15 m)
	#   Filtros : ponto navegável
	#             SEM linha de visão para a ameaça (o ponto fica escondido do player)
	#   Scores  : preferir pontos mais próximos do inimigo
	#             penalizar pontos que ficam mais perto do player do que o inimigo já está
	# Retornar o melhor ponto (Vector3) ou null.
	return null