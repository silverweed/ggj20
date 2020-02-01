extends Panel


func _input(event):
	if event.is_action_pressed("pause"):
		show()
		get_tree().paused = true
		
		
func _on_RestartButton_pressed():
	get_tree().change_scene("res://levels/Level.tscn")
	$"/root/Globals".restart()


func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://ui/MainMenu.tscn")


func _on_ResumeButton_pressed():
	get_tree().paused = false
	hide()
