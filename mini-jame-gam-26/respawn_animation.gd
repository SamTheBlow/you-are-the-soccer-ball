class_name RespawnAnimation
extends Node


@export var meshes: Array[MeshInstance3D]

var _i: int = 0
var _timer: Timer


func play() -> void:
	_i = 0
	_update_animation()


func _on_timer_timeout() -> void:
	_update_animation()


func _update_animation() -> void:
	if _timer:
		_timer.queue_free()
		_timer = null
	
	var alpha: float = 0.5
	if _i % 2:
		alpha = 1.0
	
	for mesh in meshes:
		if mesh.mesh.has_method("get_material"):
			(mesh.mesh.material as Material).albedo_color.a = alpha
	
	if _i >= 5:
		return
	
	_timer = Timer.new()
	_timer.wait_time = 0.5
	_timer.timeout.connect(_on_timer_timeout)
	add_child(_timer)
	_timer.start()
	
	_i += 1
