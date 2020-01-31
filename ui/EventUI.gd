extends Control

var event_description: String

onready var description = $Panel/DialogBox


func _ready():
	$"/root/Globals".connect("event_started", self, "on_event_started")
	
	
func _on_Button_pressed():
	hide()


func _on_EventUI_visibility_changed():
	description.display_all(event_description.split("\n\n"))


func on_event_started(event: EventsDB.Event):
	event_description = event.description
	show()
