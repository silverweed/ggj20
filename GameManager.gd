extends Node

var gameover_processed = false
var time = 0.0
var fuffa = false

onready var globals = $"/root/Globals"

func _ready():
	globals.events.load_events("events.txt")
	
	
func _process(delta):
	if !gameover_processed and \
			globals.check_gameover() != Globals.Gameover_State.Not_Game_Over:
		gameover_processed = true
		print("Game over!")
		return
		
	time += delta
	if time > 2.0 and !fuffa:
		fuffa = true
		# FIXME TODO MADAFFACCA
		globals.run_event("the_dragon_attacks")
