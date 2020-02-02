extends Node

signal stat_changed(name, new_value)
signal event_started(event, stats_changed, mods_changed)
signal event_choice_selected(event, n_choice)

var stats_cur = {}

var stats_max = {
	"integrity": 100,
	"fuel": 100,
	"ammo": 100,
	"inhabitants": 100,
	"seeds": 100,
	"mats": 100,
	"milestone": 20
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
		if key == "integrity":
			stats_cur[key] = stats_max[key]
		elif key == "fuel":
			stats_cur[key] = 20
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


# name can be an Event id or a Proxy_Event id
func run_event(name: String):
	var proxy_recursion = 0
	var orig_name = name
	while events.proxies.has(name):
		var prev_name = name
		name = follow_proxy(events.proxies[name])
		print("[note] following proxy ", prev_name, " -> ", name) 
		proxy_recursion += 1
		if proxy_recursion > 64:
			print("[error] Proxy recursion exceeded (starting from ", name, ")")
			return
		
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


# Applies changes and returns next event id
func follow_proxy(proxy: EventTypes.Proxy_Event) -> String:
	apply_stat_changes(proxy.stat_changes)
	apply_mod_changes(proxy.mod_changes)
	return eval_event_choice_outcome(proxy.choice, proxy)
	

func eval_event_choice_outcome(choice: EventTypes.Event_Choice, dbg_event = null) -> String:
	var stats = stats_cur
	var chances = []
	var cum_perc = 0
	for outcome in choice.outcomes:
		var percent = EventParser.compute_chance_expr(
			outcome.chance_expr, stats, player.modules)
		percent = min(100 - cum_perc, percent)
		cum_perc += percent
		chances.push_back(cum_perc)
		if cum_perc >= 100:
			break
	
	# Ensure choices sum to 100
	if chances[len(chances) - 1] < 100:
		var title = dbg_event.title if dbg_event else "?"
		print("[notice] choice ", title, ":", choice.description, " has outcomes not summing up to 100.")
		print("[notice] description is: ", dbg_event.description if dbg_event else "???")
	chances[len(chances) - 1] = 100
		
	var r = rand_range(0, 100)
	for i in range(0, len(chances)):
		if r <= chances[i]:
			return choice.outcomes[i].linked_event
	
	assert(len(choice.outcomes) == 0, "Choice not made!")
	return ""
	
	
# Vlambeer senpai.
func do_screenshake():
	if !screenshake_sys:
		print("[warning] no screenshake system!")
		return
	screenshake_sys.screenshake(4, 0.3, false, true)
	
