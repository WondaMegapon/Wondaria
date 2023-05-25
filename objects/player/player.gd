extends CharacterBody3D

# Setting constants for this player
const SPEED_GROUND = 1.5
const SPEED_AIR = 1.0
const DRAG_GROUND = 0.100
const DRAG_AIR = 0.100
const JUMP_VELOCITY = 5
const TURNING_SPEED = 0.9

const H_LOOK_SENS = 4.0
const V_LOOK_SENS = 4.0

# Grabbing referenced nodes and settings.
@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var cam = $PlayerCameraPivot

# Handling physics processes.
func _physics_process(delta):
	# Grabbing user input and grabbing the user direction from that.
	var raw_input_vector = Input.get_vector("player_left", "player_right", "player_forward", "player_backward") # The raw input direction.
	var input_vector = (transform.basis * Vector3(raw_input_vector.x, 0, raw_input_vector.y)).clamp(-Vector3.ONE, Vector3.ONE) # The input direction relative to the player.
	var camera_vector = Input.get_vector("camera_left", "camera_right", "camera_forward", "camera_backward") # The camera inputs.
	var move_vector = Vector3.ZERO # Processing the input and directions we get from the previous
	
	# Handling the camera.
	cam.rotation_degrees.x = clamp(cam.rotation_degrees.x - camera_vector.y * V_LOOK_SENS, -90, 90)
	cam.rotation_degrees.y -= camera_vector.x * H_LOOK_SENS
	
	# Handle the user's inital jump.
	if Input.is_action_pressed("player_jump") and is_on_floor():
		velocity.y += JUMP_VELOCITY
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta * (1.0 if Input.is_action_pressed("player_jump") else 2.0)
	
	# Adding the user's direction to the velocity.
	move_vector.x += input_vector.x * (SPEED_GROUND if is_on_floor() else SPEED_AIR)
	move_vector.z += input_vector.z * (SPEED_GROUND if is_on_floor() else SPEED_AIR)
	
	# Handing the player looking in the direction they're moving
	move_vector = move_vector.rotated(Vector3.UP, cam.rotation.y)
	
	# Applying drag to the player after we move them.
	velocity.x = lerp(velocity.x + move_vector.x, 0.0, DRAG_GROUND if is_on_floor() else DRAG_AIR)
	velocity.z = lerp(velocity.z + move_vector.z, 0.0, DRAG_GROUND if is_on_floor() else DRAG_AIR)
	
	move_and_slide()
