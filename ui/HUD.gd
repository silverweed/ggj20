extends Control

onready var dialog = $DialogBox

# Called when the node enters the scene tree for the first time.
func _ready():
	dialog.display_all(["test", "test", "such test"])

