class_name Enemy extends CharacterBody3D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var ai: BeehaveTree = $BeehaveTree

var is_moving := false

const ROTATION_SPEED = 15.0
const SPEED = 6.0

var safe_velocity: Vector3

@export var health := 100.0
@export var max_health := 100.0

@export var sight_range := 30.0
@export_range(10.0, 360.0) var sight_fov_deg := 110.0
@export_flags_3d_physics var sight_mask := 1
 
@export var muzzle: Node3D
@export var fire_interval := 0.8
@export var projectile_scene: PackedScene
var _last_shot_ms := 0
 

func _ready() -> void:
	navigation_agent.velocity_computed.connect(Callable(_on_navigation_agent_3d_velocity_computed))
	navigation_agent.max_speed = SPEED
	health = max_health


func _physics_process(delta: float) -> void:
	handle_ai_locomotion(delta)


func take_damage(amount: float, source: Node = null) -> void:
	health -= amount
	if health <= 0.0:
		queue_free()
		return
		
	ai.blackboard.set_value("was_hit", true)
	if source is Node3D:
		ai.blackboard.set_value("target", source)


func can_see(target: Node3D) -> bool:
	var eye := global_position + Vector3.UP * 1.6
	var aim := target.global_position + Vector3.UP * 1.0
	var to_target := aim - eye
	if to_target.length() > sight_range:
		return false

	var forward := -global_transform.basis.z
	if rad_to_deg(forward.angle_to(to_target)) > sight_fov_deg * 0.5:
		return false

	var query := PhysicsRayQueryParameters3D.create(eye, aim, sight_mask, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.collider == target
 

func face_toward(point: Vector3) -> void:
	var flat := Vector3(point.x, global_position.y, point.z)
	if flat.distance_squared_to(global_position) > 0.001:
		look_at(flat, Vector3.UP)
 

func handle_ai_locomotion(delta):
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		move_and_slide()
	else:
		velocity.y = 0.0

	var move_amount = clampf(abs(velocity.x) + abs(velocity.z), 0, 2)
	animation_tree.set("parameters/Locomotion/blend_position", snapped(move_amount, .5))


func apply_impulse(impulse: Vector3):
	velocity += impulse
	move_and_slide()

	
func _on_navigation_agent_3d_velocity_computed(_safe_velocity: Vector3) -> void:
	safe_velocity = _safe_velocity
 

func move_to_point(point: Vector3, tolerance := 1.0) -> bool:
	if global_position.distance_to(point) <= tolerance:
		navigation_agent.velocity = Vector3.ZERO
		velocity = Vector3.ZERO
		return true
 
	navigation_agent.target_position = point
	if navigation_agent.is_navigation_finished():
		navigation_agent.velocity = Vector3.ZERO
		velocity = Vector3.ZERO
		return true
		
	var direction := navigation_agent.get_next_path_position() - global_position
	direction.y = 0.0
	var desired_velocity = direction.normalized() * navigation_agent.max_speed

	navigation_agent.velocity = desired_velocity

	velocity.x = safe_velocity.x
	velocity.z = safe_velocity.z

	face_toward(global_position + direction)

	move_and_slide()
	return false


func try_shoot(target: Node3D) -> void:
	var now := Time.get_ticks_msec()
	if now - _last_shot_ms < int(fire_interval * 1000.0):
		return

	_last_shot_ms = now
	if projectile_scene == null:
		return

	var p := projectile_scene.instantiate() as Arrow
	get_tree().current_scene.add_child(p)
	p.global_position = muzzle.global_position
	p.look_at(target.global_position + Vector3.UP, Vector3.UP)
	p.source = self