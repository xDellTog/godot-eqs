class_name Manny extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@export var avoidance_enabled := true

@export var target: Node3D
var originalPosition: Vector3
@export var debug := false

@export var eqs_query: EQSQuery
var eqs_context: EQSContext

var snapped_speed := 0.0
var is_moving := false

const ROTATION_SPEED = 15.0
const SPEED = 5.0
const JUMP_VELOCITY = 4.5

signal finish_locomotion()

func _ready() -> void:
	if avoidance_enabled:
		navigation_agent.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))

	if eqs_query != null:
		eqs_context = eqs_query._get_context()
	
	originalPosition = global_position;

func _on_timer_timeout() -> void:
	if navigation_agent.is_navigation_finished():
		if target:
			var distance = global_position.distance_to(target.global_position)
			if distance > 2.0:
				set_target_position(target.global_position)
			else:
				set_target_position(originalPosition)
		else:
			if eqs_query != null:
				var result := eqs_query.execute()

				if result.winner != null:
					set_target_position(result.winner.position)


func _physics_process(delta: float) -> void:
	handle_ai_locomotion(delta)


func set_target_position(target_position: Vector3):
	var map := get_world_3d().navigation_map
	var closest_point := NavigationServer3D.map_get_closest_point(map, target_position)
	navigation_agent.target_position = closest_point


func handle_ai_locomotion(delta):
	# if is_on_floor():
	if navigation_agent.is_navigation_finished():
		if is_moving:
			finish_locomotion.emit()
			
		is_moving = false
		_on_navigation_agent_3d_velocity_computed(Vector3(0, 0, 0), 'stopping_internal')
		return

	var next_position := navigation_agent.get_next_path_position()
	var direction := global_position.direction_to(next_position)
	rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * ROTATION_SPEED)
	# if not is_on_floor():
	# 	new_velocity += get_gravity() * delta

	if navigation_agent.avoidance_enabled and avoidance_enabled:
		is_moving = true
		# navigation_agent.velocity = (next_position - global_position).normalized() * SPEED
		navigation_agent.velocity = Vector3(direction.x, 0, direction.z) * navigation_agent.max_speed
	else:
		is_moving = true
		_on_navigation_agent_3d_velocity_computed(Vector3(direction.x, 0, direction.z) * navigation_agent.max_speed, 'internal')
	pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3, _from := "signal") -> void:
	velocity = safe_velocity
	var move_amount = clampf(abs(velocity.x) + abs(velocity.z), 0, 2)
	animation_tree.set("parameters/Locomotion/Locomotion/blend_position", snapped(move_amount, .5))
	move_and_slide()
