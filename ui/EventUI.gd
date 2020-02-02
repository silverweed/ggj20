class_name EventUI
extends Control

signal choice_selected(event, n_choice)

var event_description: String
var cur_event: EventTypes.Event
# Maps index of filtered choices with those of the complete choices.
var cur_event_filtered_choices_indices = []
var cur_event_stats_changed = []
var cur_event_mods_changed = []
var stats_change_shown = false

onready var description: DialogBox = $DialogBox
onready var choices: ChoiceContainer = $ChoicesContainer
onready var globals = $"/root/Globals"


func _ready():
	$"/root/Globals".connect("event_started", self, "on_event_started")
	description.connect("all_displayed", self, "on_all_displayed")
	choices.connect("choice_selected", self, "on_choice_selected")
	choices.owner = self


# stats_changed: [Stat_Change]
# mods_changed: [Stat_Change]
func on_event_started(event: EventTypes.Event, stats_changed, mods_changed):
	cur_event = event
	cur_event_stats_changed = stats_changed
	cur_event_mods_changed = mods_changed
	stats_change_shown = false
	event_description = event.description
	choices.hide()
	description.display_all(event_description.split("\n\n"))


func on_all_displayed():
	if stats_change_shown or len(cur_event_stats_changed) == 0:
		var choice_desc = []
		var i = 0
		var res = eval_and_filter_choices(cur_event.choices)
		for c in res[0]:
			var desc = c.description if c.description.length() > 0 else "..."
			choice_desc.push_back(desc)
		cur_event_filtered_choices_indices = res[1]
		choices.show_choices(choice_desc)
	else:
		stats_change_shown = true
		var string = prettify_stat_changes(cur_event_stats_changed)
		string += "\n" + prettify_stat_changes(cur_event_mods_changed)
		description.display_all([string])


func prettify_stat_changes(stat_changes) -> String:
	var pretty = ""
	# Collapse stat changes
	var collapsed = {}
	for change in stat_changes:
		var s_name = change[0]
		if s_name == "milestone":
			continue
		if collapsed.has(s_name):
			var c = collapsed[s_name]
			collapsed[s_name] = [c[0] + change[1], c[1] + change[2]]
		else:
			collapsed[s_name] = [change[1], change[2]]
			
	for s_name in collapsed:
		var change = collapsed[s_name]
		var s_intended_change = change[0]
		var s_actual_change = change[1]
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
	assert(len(cur_event_filtered_choices_indices) > n)
	var orig_choice_idx = cur_event_filtered_choices_indices[n]
	emit_signal("choice_selected", cur_event, orig_choice_idx)
	
	
func eval_and_filter_choices(all_choices): # -> [[Choice], [int]]
	var filtered = []
	var index_map = []
	var i = 0
	for choice in all_choices:
		var percent = EventParser.compute_chance_expr(
				choice.chance_expr, globals.stats_cur, globals.player.modules)
		if rand_range(0, 100) < percent:
			filtered.append(choice)
			index_map.append(i)
		i += 1
	return [filtered, index_map]
