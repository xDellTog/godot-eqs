class_name Manny extends CharacterBody3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
 

const ROTATION_SPEED = 15.0
const SPEED = 4.0
const JUMP_VELOCITY = 4.5


func _physics_process(delta: float) -> void:
	handle_ai_locomotion(delta)
	pass


func set_target_position(target_position: Vector3):
	var map := get_world_3d().navigation_map
	var closest_point := NavigationServer3D.map_get_closest_point(map, target_position)
	navigation_agent.target_position = closest_point
	pass


func handle_ai_locomotion(delta):
	if is_on_floor():
		if navigation_agent.is_navigation_finished():
			velocity.x = 0
			velocity.z = 0

			animation_tree.set("parameters/Locomotion/conditions/is_moving", false)
			animation_tree.set("parameters/Locomotion/conditions/is_not_moving", true)
			animation_tree.set("parameters/Locomotion/Locomotion/blend_position", 0)
			
			move_and_slide()
			return

		var next_position := navigation_agent.get_next_path_position()
		var direction := global_position.direction_to(next_position)
		var distance := navigation_agent.get_path_length()

		var snapped_speed = 2.0 if distance > 5.0 else 1.0
  
		velocity.x = direction.x * snapped_speed * SPEED
		velocity.z = direction.z * snapped_speed * SPEED

		rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z), delta * ROTATION_SPEED)

		animation_tree.set("parameters/Locomotion/conditions/is_moving", true)
		animation_tree.set("parameters/Locomotion/conditions/is_not_moving", false)
		animation_tree.set("parameters/Locomotion/Locomotion/blend_position", snapped_speed)

		move_and_slide()
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
