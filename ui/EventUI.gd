class_name EventUI
extends Control

signal choice_selected(event, n_choice)

var event_description: String
var cur_event: EventTypes.Event
var cur_event_stats_changed = []
var stats_change_shown = false

onready var description: DialogBox = $DialogBox
onready var choices: ChoiceContainer = $ChoicesContainer


func _ready():
	$"/root/Globals".connect("event_started", self, "on_event_started")
	description.connect("all_displayed", self, "on_all_displayed")
	choices.connect("choice_selected", self, "on_choice_selected")
	choices.owner = self


func on_event_started(event: EventTypes.Event, stats_changed):
	cur_event = event
	cur_event_stats_changed = stats_changed
	stats_change_shown = false
	event_description = event.description
	choices.hide()
	description.display_all(event_description.split("\n\n"))


func on_all_displayed():
	if stats_change_shown:
		var choice_desc = []
		for c in cur_event.choices:
			choice_desc.push_back(c.description)
		choices.show_choices(choice_desc)
	else:
		stats_change_shown = true
		description.display_all([prettify_stat_changes(cur_event_stats_changed)])


func prettify_stat_changes(stat_changes) -> String:
	var pretty = ""
	for change in stat_changes:
		var s_name = change[0]
		var s_intended_change = change[1]
		var s_actual_change = change[2]
		var verb = "found" if s_intended_change > 0 else "lost"
		pretty += "You " + verb + " " + str(abs(s_intended_change)) + " " + s_name
		if s_intended_change > 0 and s_intended_change != s_actual_change:
			if s_actual_change > 0:
				pretty += ", but you could only gain " + str(s_actual_change)
			else:
				pretty += ", but you had space for none"
		pretty += ".\n"
		
	return pretty
	
	
func on_choice_selected(n: int):
	emit_signal("choice_selected", cur_event, n)
