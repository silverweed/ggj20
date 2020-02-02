extends Control


func _input(event):
	if event.is_action_type("ui_cancel"):
		get_tree().change_scene("res://levels/Level.tscn")
