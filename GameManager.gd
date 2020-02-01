extends Node

var gameover_processed = false
var time = 0.0
var fuffa = false
var event_ui: EventUI

onready var globals = $"/root/Globals"


func _ready():
	globals.events.load_events("events.txt")
	var event_uis = get_tree().get_nodes_in_group("event_ui")
	if len(event_uis) > 0:
		event_ui = event_uis[0]
		if event_ui != null:
			event_ui.connect("choice_selected", self, "on_event_choice_selected")
	
	
func _process(delta):
	if !gameover_processed and \
			globals.check_gameover() != Globals.Gameover_State.Not_Game_Over:
		gameover_processed = true
		print("Game over!")
		return
		
	time += delta
	if time > 1.0 and !fuffa:
		fuffa = true
		# FIXME TODO MADAFFACCA
		globals.run_event("the_dragon_attacks")
		
		
func on_event_choice_selected(event: EventTypes.Event, n_choice: int):
	print("selected ", n_choice)
