extends HBoxContainer

var selected = false setget set_selected
var text setget set_text, get_text

func _ready():
	selected = false
	$AnimationPlayer.play("Deselected")
	
	
func set_selected(s: bool):
	selected = s
	$AnimationPlayer.play("Selected" if selected else "Deselected")


func set_text(t: String):
	$Label.text = t


func get_text() -> String:
	return $Label.text
