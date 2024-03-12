class_name SoccerCar
extends Node3D


@export var team: int = 1

@onready var body := $VehicleBody3D as VehicleBody3D
@onready var stuck_timer := $StuckTimer as Timer
@onready var respawn_animation := $RespawnAnimation as RespawnAnimation

@onready var _starting_position: Vector3 = global_position
@onready var _starting_rotation: Vector3 = global_rotation

var playing: bool = false


func _ready() -> void:
	var body_mesh := $VehicleBody3D/CarBody as MeshInstance3D
	body_mesh.mesh = body_mesh.mesh.duplicate()
	body_mesh.mesh.material = body_mesh.mesh.material.duplicate()
	var wheel1 := $VehicleBody3D/VehicleWheel3D/MeshInstance3D as MeshInstance3D
	var wheel2 := $VehicleBody3D/VehicleWheel3D2/MeshInstance3D as MeshInstance3D
	var wheel3 := $VehicleBody3D/VehicleWheel3D3/MeshInstance3D as MeshInstance3D
	var wheel4 := $VehicleBody3D/VehicleWheel3D4/MeshInstance3D as MeshInstance3D
	wheel1.mesh = wheel1.mesh.duplicate()
	wheel1.mesh.material = wheel1.mesh.material.duplicate()
	wheel2.mesh = wheel2.mesh.duplicate()
	wheel2.mesh.material = wheel2.mesh.material.duplicate()
	wheel3.mesh = wheel3.mesh.duplicate()
	wheel3.mesh.material = wheel3.mesh.material.duplicate()
	wheel4.mesh = wheel4.mesh.duplicate()
	wheel4.mesh.material = wheel4.mesh.material.duplicate()
	var sunglasses := $VehicleBody3D/Sunglasses as MeshInstance3D
	sunglasses.mesh = sunglasses.mesh.duplicate()
	sunglasses.mesh.material = sunglasses.mesh.material.duplicate()
	
	var i: int = 2
	while get_node_or_null("VehicleBody3D/CarBody" + str(i)):
		var node: Node = get_node("VehicleBody3D/CarBody" + str(i))
		node.mesh = node.mesh.duplicate()
		node.mesh.material = body_mesh.mesh.material
		i += 1
	
	if team == 1:
		body_mesh.mesh.material.albedo_color = Color.ORANGE
	elif team == 2:
		body_mesh.mesh.material.albedo_color = Color.BLUE


func _physics_process(_delta: float) -> void:
	var is_stuck: bool = false
	
	if not playing:
		return
	
	if body.linear_velocity.length() < 1.0:
		is_stuck = true
	if body.global_rotation.x < -PI or body.global_rotation.x > PI:
		is_stuck = true
	if body.global_rotation.z < -PI * 0.4 or body.global_rotation.z > PI * 0.4:
		is_stuck = true
	if is_stuck:
		if stuck_timer.time_left == 0.0:
			stuck_timer.start()
	else:
		stuck_timer.stop()
	
	var ball: SoccerBall = _ball()
	if not ball:
		return
	
	# Go towards the ball
	var car_angle: float = body.global_rotation.y
	
	var direction: Vector3 = body.global_position - ball.body.global_position
	var ball_angle: float = atan2(-direction.z, direction.x)
	if ball_angle >= 0.0:
		ball_angle = -PI + ball_angle
	else:
		ball_angle = PI + ball_angle
	
	var steering: float = ball_angle - car_angle
	if steering < -PI:
		steering += 2.0 * PI
	if steering > PI:
		steering -= 2.0 * PI
	steering = clampf(steering, -PI * 0.3, PI * 0.3)
	var force: float = 300.0
	
	#if name == "Car5":
	#	print("--- ", name)
	#	print("Car angle: ", car_angle)
	#	print("Ball angle: ", ball_angle)
	#	print("Steering: ", steering)
	
	body.steering = steering
	body.engine_force = force


func _ball() -> SoccerBall:
	var nodes: Array[Node] = get_tree().get_nodes_in_group("player")
	for node in nodes:
		if node is SoccerBall:
			return node as SoccerBall
	return null


func _on_stuck_timer_timeout() -> void:
	#body.global_position.x = clampf(body.global_position.x, -45.0, 45.0)
	#body.global_position.y = 5.0
	#body.global_position.z = clampf(body.global_position.z, -30.0, 30.0)
	#body.global_rotation.x = 0.0
	#body.global_rotation.z = 0.0
	body.global_position = _starting_position
	body.global_rotation = _starting_rotation
	body.angular_velocity = Vector3.ZERO
	body.linear_velocity = Vector3.ZERO
	respawn_animation.play()
