class_name ExplosionAnimation
extends Node


@export var explosion_effect_scene: PackedScene
@export var ball: SoccerBall

var _playing: bool = false
var _i: int = 0


func play() -> void:
	(ball.body.get_node("OmniLight3D") as OmniLight3D).hide()
	(ball.body.get_node("CSGSphere3D") as CSGSphere3D).hide()
	ball.body.remove_child(ball.body.get_node("CollisionShape3D"))
	ball.body.freeze = true
	ball.body.angular_velocity = Vector3.ZERO
	ball.body.linear_velocity = Vector3.ZERO
	
	_playing = true
	_i = 0


func _process(_delta: float) -> void:
	if (not _playing) or _i >= 100:
		return
	
	var explosion_effect := explosion_effect_scene.instantiate() as Node3D
	
	explosion_effect.rotation = Vector3(
		randf() * 2.0 * PI,
		randf() * 2.0 * PI,
		randf() * 2.0 * PI
	)
	
	explosion_effect.scale = ball.radius * Vector3(
		randf_range(1.0, 10.0),
		randf_range(0.1, 2.0),
		1.0
	)
	
	ball.body.add_child(explosion_effect)
	
	_i += 1
