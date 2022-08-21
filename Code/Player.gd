extends KinematicBody

var speed = 10
var run_speed = 1.5
var acceleration = 10
var air_resistance = 1
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
	if Input.is_action_pressed("ui_cancel"):
		get_tree().quit()
		
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
	
	velocity = move_and_slide_with_snap(velocity, snap, Vector3.UP, true, 4, 0.785398, false)
