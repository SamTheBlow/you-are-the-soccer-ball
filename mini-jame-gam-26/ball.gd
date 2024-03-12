@tool
class_name SoccerBall
extends Node3D


@export var body: RigidBody3D
@export var raycast: RayCast3D

@export var speed: float = 100.0
@export var jump_strength: float = 30.0
@export var radius: float = 1.0 : set = _on_set_radius

var _is_on_floor: bool = false

@onready var sphere := $RigidBody3D/CSGSphere3D as CSGSphere3D
@onready var collision_shape := $RigidBody3D/CollisionShape3D as CollisionShape3D
@onready var explosion_animation := $ExplosionAnimation as ExplosionAnimation


func _process(_delta: float) -> void:
	_is_on_floor = false
	
	if not raycast.is_colliding():
		return
	_is_on_floor = (body.global_position.y - raycast.get_collision_point().y) < radius + 0.25


func _physics_process(delta: float) -> void:
	var input_direction: Vector2 = Vector2.ZERO
	
	if InputMap.has_action("move_left"):
		input_direction = Input.get_vector(
				"move_left", "move_right", "move_up", "move_down"
		)
	
	var force_y: float = 0.0
	if _is_on_floor and Input.is_action_just_pressed("jump"):
		force_y = jump_strength
	
	var direction := Vector3(input_direction.x, force_y, input_direction.y)
	body.apply_central_force(direction * speed * delta)


func _on_set_radius(new_value: float) -> void:
	radius = new_value
	if sphere and collision_shape:
		sphere.radius = radius
		collision_shape.shape.radius = radius


func explode() -> void:
	explosion_animation.play()
