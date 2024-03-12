extends Node


signal game_started()


func _on_play_button_pressed() -> void:
	game_started.emit()
