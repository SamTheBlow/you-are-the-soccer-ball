extends SpotLight3D


@export var ball: SoccerBall

var _original_position: Vector3


func _ready() -> void:
	_original_position = global_position


func _process(_delta: float) -> void:
	global_position = ball.body.global_position + _original_position
