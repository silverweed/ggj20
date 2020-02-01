extends Node

var gameover_processed = false
var time = 0.0
var fuffa = false

onready var globals = $"/root/Globals"

func _ready():
	globals.events.load_events("events.txt")
	EventParser.compute_chance_expr("3 + hull*2-3*fuel", Globals.stats_cur)
	EventParser.compute_chance_expr("10*5", Globals.stats_cur)
	
	
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
