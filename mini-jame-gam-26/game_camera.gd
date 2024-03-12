class_name GameCamera
extends Camera3D


@export var player: SoccerBall

var _lock_z: float = 0.0


func _ready() -> void:
	_lock_z = position.z


func _process(delta: float) -> void:
	if not current:
		return
	
	var target_position := Vector3(player.body.global_position)
	target_position.z += 20.0
	target_position.z = clampf(target_position.z, -40.0, 40.0)
	target_position.y = clampf(target_position.y, 5.0, 100.0)
	
	if target_position.z >= 10.0:
		target_position.y += (target_position.z - 10.0) * 1.0
	
	global_position -= (global_position - target_position) * player.body.linear_velocity.length() * delta
	
	look_at(player.body.global_position)
	rotation_degrees.y = 0.0
