class_name GameManager
extends Node

signal gameover

var is_gameover = false
var time = 0.0
var fuffa = false
var event_ui: EventUI

onready var globals = $"/root/Globals"


func _ready():
	randomize()
	
	globals.game_mgr = self
	globals.events.load_events("events.txt")
	var event_uis = get_tree().get_nodes_in_group("event_ui")
	if len(event_uis) > 0:
		event_ui = event_uis[0]
		if event_ui != null:
			event_ui.connect("choice_selected", self, "on_event_choice_selected")
	

func _exit_tree():
	if globals.game_mgr == self:
		globals.game_mgr = null
	
	
func _process(delta):
	if !is_gameover and globals.check_gameover() != Globals.Gameover_State.Not_Game_Over:
		is_gameover = true
		gameover()
		return
		
	time += delta
	if !fuffa:
		fuffa = true
		# FIXME TODO MADAFFACCA
		globals.run_event("a")
		
		
func on_event_choice_selected(event: EventTypes.Event, n_choice: int):
	var next_evt = eval_event_choice_outcome(event.choices[n_choice])
	if next_evt != "":
		globals.run_event(next_evt)


func eval_event_choice_outcome(choice: EventTypes.Event_Choice) -> String:
	var stats = Globals.stats_cur
	var chances = []
	var cum_perc = 0
	for outcome in choice.outcomes:
		if outcome.chance_expr == "":
			chances.push_back(100)
			break
			
		var percent = EventParser.compute_chance_expr(outcome.chance_expr, stats)
		percent = min(100 - cum_perc, percent)
		cum_perc += percent
		chances.push_back(cum_perc)
		if cum_perc >= 100:
			break
	
	var r = rand_range(0, 100)
	for i in range(0, len(chances)):
		if r <= chances[i]:
			return choice.outcomes[i].linked_event
	
	assert(len(choice.outcomes) == 0, "Choice not made!")
	return ""


func gameover():
	emit_signal("gameover")
