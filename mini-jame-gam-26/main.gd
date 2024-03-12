extends Node


@export var main_menu_scene: PackedScene
@export var game_scene: PackedScene


func _ready() -> void:
	_open_main_menu()


func _on_play_button_pressed() -> void:
	var game: Node = game_scene.instantiate()
	game.play_again.connect(_on_play_button_pressed)
	_change_scene(game)


func _on_returned_to_main_menu() -> void:
	_open_main_menu()


func _open_main_menu() -> void:
	var main_menu: Node = main_menu_scene.instantiate()
	main_menu.game_started.connect(_on_play_button_pressed)
	_change_scene(main_menu)


func _change_scene(scene: Node) -> void:
	for child in get_children():
		remove_child(child)
	
	add_child(scene)
