class_name Player extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D

var is_moving := false

const ROTATION_SPEED = 15.0
const SPEED = 6.0

var safe_velocity: Vector3

signal finish_locomotion()

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))
	navigation_agent.max_speed = SPEED


func _physics_process(delta: float) -> void:
	handle_ai_locomotion(delta)
	

func set_target_position(target_position: Vector3):
	var map := get_world_3d().navigation_map
	var closest_point := NavigationServer3D.map_get_closest_point(map, target_position)
	navigation_agent.target_position = closest_point


func handle_ai_rotation(delta):
	var next_position := navigation_agent.get_next_path_position()
	var direction := next_position.direction_to(global_position)
	rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * ROTATION_SPEED)


func handle_ai_locomotion(delta):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = 0.0

	var desired_velocity := Vector3.ZERO
	if is_on_floor():
		if navigation_agent.is_navigation_finished():
			if is_moving:
				finish_locomotion.emit()
			is_moving = false
		else:
			handle_ai_rotation(delta)
			
			var next_position := navigation_agent.get_next_path_position()
			var direction := global_position.direction_to(next_position)
			desired_velocity = Vector3(direction.x, 0, direction.z).normalized() * navigation_agent.max_speed
			is_moving = true
	
	navigation_agent.velocity = desired_velocity
	
	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

	var move_amount = clampf(abs(velocity.x) + abs(velocity.z), 0, 2)
	animation_tree.set("parameters/Locomotion/blend_position", snapped(move_amount, .5))
	
	move_and_slide()

	
func _on_navigation_agent_3d_velocity_computed(_safe_velocity: Vector3) -> void:
	safe_velocity = _safe_velocity