extends Control


onready var underline = $Underline

func _ready():
	$AnimationPlayer.play("Blink")
	
	
func _on_Quit_pressed():
	get_tree().quit()


func _on_Play_pressed():
	get_tree().change_scene("res://levels/Level.tscn")


func move_underline(node: Control):
	underline.rect_global_position.y = node.rect_global_position.y + 150


func _on_Play_mouse_entered():
	move_underline($VBoxContainer2/VBoxContainer/Play)
	

func _on_Credits_mouse_entered():
	move_underline($VBoxContainer2/VBoxContainer/Credits)


func _on_Quit_mouse_entered():
	move_underline($VBoxContainer2/VBoxContainer/Quit)
