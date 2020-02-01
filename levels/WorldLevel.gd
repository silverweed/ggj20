extends Node2D


func _ready():
	var gm = get_tree().get_nodes_in_group("game_mgr")
	if len(gm) > 0:
		gm[0].connect("gameover", self, "on_gameover")


func on_gameover():
	get_tree().paused = true
