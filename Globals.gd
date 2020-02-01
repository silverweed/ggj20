extends Node

signal stat_changed(name, new_value)
signal event_started(event)
signal event_choice_selected(event, n_choice)

var stats_cur = {}

var stats_max = {
	"hull": 20,
	"fuel": 20,
	"weapons": 100,
	"inhabitants": 50,
	"seeds": 30,
	"materials": 100
}

var events: EventsDB
var game_mgr: GameManager

func _ready():
	events = EventsDB.new()
	restart()
	

func restart():
	stats_cur.clear()
	for key in stats_max:
		if key == "fuel" or key == "hull":
			stats_cur[key] = stats_max[key]
		else:
			stats_cur[key] = 0
		

func add_stat(name: String, value: int):
	print("add_Stat(", name, ", ", value, ")")
	set_stat(name, get_stat(name) + value)


func set_stat(name: String, value: int):
	name = name.to_lower()
	assert(stats_cur.has(name), "Inexisting stat " + name + "!")
	
	stats_cur[name] = clamp(value, 0, stats_max[name])
	emit_signal("stat_changed", name, value)


func get_stat(name: String) -> int:
	name = name.to_lower()
	assert(stats_cur.has(name), "Inexisting stat " + name + "!")
	return stats_cur[name]
	

func add_stat_max(name: String, value: int):
	set_stat_max(name, get_stat_max(name) + value)


func set_stat_max(name: String, value: int):
	name = name.to_lower()
	assert(stats_max.has(name), "Inexisting stat " + name + "!")
	
	stats_max[name] = value
	
	# Ensure stat cur is not above max
	var prev_stat = stats_cur[name]
	stats_cur[name] = clamp(prev_stat, 0, stats_max[name])
	if stats_cur[name] != prev_stat:
		emit_signal("stat_changed", name, stats_cur[name])


func get_stat_max(name: String) -> int:
	name = name.to_lower()
	assert(stats_max.has(name), "Inexisting stat " + name + "!")
	return stats_max[name]
	

enum Gameover_State {
	Not_Game_Over,
	Hull_Depleted,
	Fuel_Depleted
}

func check_gameover():
	if stats_cur["hull"] <= 0:
		return Gameover_State.Hull_Depleted
	
	if stats_cur["fuel"] <= 0:
		return Gameover_State.Fuel_Depleted
		
	return Gameover_State.Not_Game_Over


func run_event(name: String):
	if !events.has(name):
		print("[warning] inexisting event ", name)
		return
	
	var event: EventTypes.Event = events.get(name)
	apply_stat_changes(event)
	emit_signal("event_started", event)


func apply_stat_changes(event: EventTypes.Event):
	for change in event.stat_changes:
		var percent = EventParser.compute_chance_expr(change.chance_expr, stats_cur)
		print("% = ", percent)
		if rand_range(0, 100) < percent:
			add_stat(change.stat_name, change.change)
