extends Control

onready var dialog = $DialogBox

# Called when the node enters the scene tree for the first time.
func _ready():
	dialog.display_all(["test", "test", "such test"])

func _input(event):
	if event.is_action_pressed("advance_text"):
		$"/root/Globals".add_stat("hull", -10)
