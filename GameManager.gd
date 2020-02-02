class_name GameManager
extends Node

signal gameover

var is_gameover = false
var event_ui: EventUI

onready var globals = $"/root/Globals"


func _ready():
	randomize()
	
	globals.game_mgr = self
	if globals.events.events.empty():
		globals.events.load_events("base_events.txt")
		globals.events.load_events("event_pack_1.txt")
		globals.events.load_events("event_pack_2.txt")
#		globals.events.load_events("test_events.txt")
		
	var event_uis = get_tree().get_nodes_in_group("event_ui")
	if len(event_uis) > 0:
		event_ui = event_uis[0]
		if event_ui != null:
			event_ui.connect("choice_selected", self, "on_event_choice_selected")
	else:
		print("[WARNING] no event ui!")
		
	call_deferred("run_master_event")
		
func run_master_event():
	globals.run_event("home")


func _exit_tree():
	if globals.game_mgr == self:
		globals.game_mgr = null
	
	
func _process(delta):
	if !is_gameover and globals.check_gameover() != Globals.Gameover_State.Not_Game_Over:
		is_gameover = true
		gameover()
		return
		
		
func on_event_choice_selected(event: EventTypes.Event, n_choice: int):
	var next_evt = eval_event_choice_outcome(event.choices[n_choice])
	if next_evt != "":
		globals.run_event(next_evt)


func eval_event_choice_outcome(choice: EventTypes.Event_Choice) -> String:
	var stats = Globals.stats_cur
	var chances = []
	var cum_perc = 0
	for outcome in choice.outcomes:
		var percent = EventParser.compute_chance_expr(
			outcome.chance_expr, stats, globals.player.modules)
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
	get_tree().paused = true
	emit_signal("gameover")
