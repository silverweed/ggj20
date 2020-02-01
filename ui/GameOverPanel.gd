extends Panel


func _ready():
	var gm = $"/root/Globals".game_mgr
	if gm:
		gm.connect("gameover", self, "show")
	

func _on_RestartButton_pressed():
	get_tree().change_scene("res://levels/Level.tscn")
	$"/root/Globals".restart()
