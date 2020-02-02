extends Node

signal stat_changed(name, new_value)
signal event_started(event, stats_changed, mods_changed)
signal event_choice_selected(event, n_choice)

var stats_cur = {}

var stats_max = {
	"integrity": 20,
	"fuel": 20,
	"ammo": 100,
	"inhabitants": 50,
	"seeds": 30,
	"materials": 100
}

var events: EventsDB
var game_mgr: GameManager
var screenshake_sys: ScreenShakeSystem
var player: PlayerBody


func _ready():
	events = EventsDB.new()
	restart()
	

func restart():
	get_tree().paused = false
	stats_cur.clear()
	for key in stats_max:
		if key == "fuel" or key == "integrity":
			stats_cur[key] = stats_max[key]
		else:
			stats_cur[key] = 0
		

func add_stat(name: String, value: int):
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
	if stats_cur["integrity"] <= 0:
		return Gameover_State.Hull_Depleted
	
	if stats_cur["fuel"] <= 0:
		return Gameover_State.Fuel_Depleted
		
	return Gameover_State.Not_Game_Over


func run_event(name: String):
	if !events.has(name):
		print("[warning] inexisting event ", name)
		return
	
	var event: EventTypes.Event = events.get(name)
	var stats_changed = apply_stat_changes(event.stat_changes)
	var mods_changed = apply_mod_changes(event.mod_changes)
	emit_signal("event_started", event, stats_changed, mods_changed)


func apply_stat_changes(all_changes): # -> [[name, intended_change, actual_change]]
	var changes = []
	for change in all_changes:
		var percent = EventParser.compute_chance_expr(change.chance_expr, stats_cur, player.modules)
		if rand_range(0, 100) < percent:
			var prev = get_stat(change.stat_name)
			add_stat(change.stat_name, change.change)
			changes.append([change.stat_name, change.change, get_stat(change.stat_name) - prev])
	return changes


func apply_mod_changes(all_changes): # -> [[name, intended_change, actual_change]]
	if player == null:
		print("[warning] no player registered")
		return
		
	var changes = []
	for change in all_changes:
		var percent = EventParser.compute_chance_expr(change.chance_expr, stats_cur, player.modules)
		if rand_range(0, 100) < percent:
			var prev = player.get_module_level(change.stat_name)
			player.set_module_level(change.stat_name, prev + change.change)
			changes.append([change.stat_name, change.change, \
					player.get_module_level(change.stat_name) - prev])
	return changes
	
	
# Vlambeer senpai.
func do_screenshake():
	if !screenshake_sys:
		return
	screenshake_sys.screenshake(10.0, 0.3, false, true)
	
