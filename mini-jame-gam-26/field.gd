class_name SoccerField
extends Node3D


signal goal_scored(which_goal: int)


func _on_goal_1_area_body_entered(_body: Node3D) -> void:
	goal_scored.emit(1)


func _on_goal_2_area_body_entered(_body: Node3D) -> void:
	goal_scored.emit(2)
