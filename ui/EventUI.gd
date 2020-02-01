class_name EventUI
extends Control

signal choice_selected(event, n_choice)

var event_description: String
var cur_event: EventTypes.Event

onready var description: DialogBox = $Panel/DialogBox
onready var choices: ChoiceContainer = $Panel/ChoicesContainer


func _ready():
	$"/root/Globals".connect("event_started", self, "on_event_started")
	description.connect("all_displayed", self, "on_all_displayed")
	choices.connect("choice_selected", self, "on_choice_selected")
	choices.owner = self
	

func _on_EventUI_visibility_changed():
	if visible:
		description.display_all(event_description.split("\n\n"))


func on_event_started(event: EventTypes.Event):
	cur_event = event
	event_description = event.description
	show()


func on_all_displayed():
	var choice_desc = []
	for c in cur_event.choices:
		choice_desc.push_back(c.description)
	choices.show_choices(choice_desc)


func on_choice_selected(n: int):
	emit_signal("choice_selected", cur_event, n)
