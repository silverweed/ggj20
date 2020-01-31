extends Node

signal stat_changed(name, new_value)
signal event_started(event)

const HULL_MAX = 20
const FUEL_MAX = 20

var stats_cur = {
	"Hull": HULL_MAX,
	"Fuel": FUEL_MAX
}

var stats_max = {
	"Hull": HULL_MAX,
	"Fuel": FUEL_MAX
}

var events: EventsDB


func _ready():
	events = EventsDB.new()
	

func add_stat(name: String, value: int):
	set_stat(name, get_stat(name) + value)


func set_stat(name: String, value: int):
	assert(stats_cur.has(name), "Inexisting stat " + name + "!")
	assert(stats_max.has(name), "Inexisting stat " + name + "!")
	
	stats_cur[name] = clamp(value, 0, stats_max[name])
	emit_signal("stat_changed", name, value)


func get_stat(name: String) -> int:
	assert(stats_cur.has(name), "Inexisting stat " + name + "!")
	assert(stats_max.has(name), "Inexisting stat " + name + "!")
	return stats_cur[name]
	

enum Gameover_State {
	Not_Game_Over,
	Hull_Depleted,
	Fuel_Depleted
}

func check_gameover():
	if stats_cur["Hull"] <= 0:
		return Gameover_State.Hull_Depleted
	
	if stats_cur["Fuel"] <= 0:
		return Gameover_State.Fuel_Depleted
		
	return Gameover_State.Not_Game_Over


func run_event(name: String):
	if !events.has(name):
		print("[warning] inexisting event ", name)
		return
		
	emit_signal("event_started", events.get(name))
