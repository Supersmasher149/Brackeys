var jump_force = 20
var gravity = 1

var mouse_sense = 0.2
var run = 1
var hold_distance = 5

var direction = Vector3.ZERO
var velocity = Vector3.ZERO
var snap = Vector3.DOWN

var grabbed = null

onready var camera = $Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation_degrees.y += -event.relative.x * mouse_sense
		camera.rotation_degrees.x += -event.relative.y * mouse_sense
		camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, -90, 90)
		
func _physics_process(delta):
	var horizontal = Input.get_action_strength("backward") - Input.get_action_strength("forward")
	var vertical = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction = (transform.basis.z * horizontal + transform.basis.x * vertical).normalized()
	
	if is_on_floor():
		if Input.is_action_pressed("run"):
			run = lerp(run, run_speed, 0.25)
			camera.fov = lerp(camera.fov, 80, 0.1)
		else:
			run = lerp(run, 1, 0.25)
			camera.fov = lerp(camera.fov, 70, 0.1)
		velocity.x = lerp(velocity.x, direction.x*(speed*run), acceleration*delta)
		velocity.z = lerp(velocity.z, direction.z*(speed*run), acceleration*delta)
		if Input.is_action_just_pressed("jump"):
			snap = Vector3.ZERO
			velocity.y = jump_force
	else:
		velocity.x = lerp(velocity.x, direction.x*speed, air_resistance*delta)
		velocity.z = lerp(velocity.z, direction.z*speed, air_resistance*delta)
		snap = Vector3.DOWN
		velocity.y -= gravity
		
	grab()
	hud()
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, 0.785398, false)
	
func grab():
	if Input.is_action_just_pressed("mouse_left"):
		#project position
		if $Camera/RayCast.is_colliding():
			if $Camera/RayCast.get_collider().is_in_group("grabbable"):
				grabbed = $Camera/RayCast.get_collider()
				grabbed.gravity_scale = 0
	if Input.is_action_just_released("mouse_left"):
		if grabbed != null:
			grabbed.gravity_scale = 10
		grabbed = null
	if Input.is_action_just_released("out"):
		hold_distance += 0.5
	if Input.is_action_just_released("in"):
		hold_distance -= 0.5
	hold_distance = clamp(hold_distance, 3, 25)
		
	if grabbed != null:
		track()
		
func track():
	var track_pos = camera.project_position(Vector2(640, 360), hold_distance)
	#grabbed.gravity_scale = 0
	grabbed.add_central_force(grabbed.transform.origin.direction_to(track_pos) * grabbed.transform.origin.distance_to(track_pos) * 75)

func hud():
	$HUD/P1Height.text = str(round(transform.origin.y))
	
#grabbed.add_central_force((track_pos - grabbed.transform.origin)*25)
#grabbed._integrate_forces()
#grabbed.transform.origin = grabbed.transform.origin.linear_interpolate(track_pos, 0.25)
#grabbed.velocity = grabbed.velocity.linear_interpolate(track_pos - grabbed.transform.origin, 5)
#grabbed.linear_velocity = grabbed.transform.origin.direction_to(track_pos) * grabbed.transform.origin.distance_to(track_pos) * 10
