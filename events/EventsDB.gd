class_name EventsDB
extends Node

	
var events = {}
var proxies = {}


func has(name: String) -> bool:
	return events.has(name)


func get(name: String) -> EventTypes.Event:
	return events[name]
	
	
func load_events(fname: String):
	var f = File.new()
	assert(f.file_exists(fname), "File " + fname + " not found!")
	f.open(fname, File.READ)
	var res = EventParser.parse_all_events(fname, f)
	var new_events = res[0]
	var new_proxies = res[1]
	f.close()
	print("[ok] loaded events from ", fname)
#	debug_print_events(new_events, new_proxies)
	for key in new_events:
		if events.has(key):
			print("[warning] overwriting duplicate event ", key)
		events[key] = new_events[key]
	for key in new_proxies:
		if proxies.has(key):
			print("[warning] overwriting duplicate proxy ", key)
		proxies[key] = new_proxies[key]
	


func debug_print_events(evts, proxs):
	print("== Events ==")
	for key in evts:
		var event: EventTypes.Event = evts[key]
		print("event ", key)
		print("title ", event.title)
		print("---")
		print(event.description)
		print("---")
		for choice in event.choices:
			print(" > [", choice.chance_expr, "] ", choice.description)
			for outcome in choice.outcomes:
				print("[", outcome.chance_expr, "] ", outcome.linked_event)
		for change in event.stat_changes:
			print("change [", change.chance_expr, "] ", change.stat_name, " ", change.change)
		for change in event.mod_changes:
			print("module [", change.chance_expr, "] ", change.stat_name, " ", change.change)
	
	print("== Proxies ==")
	for key in proxs:
		var proxy: EventTypes.Proxy_Event = proxs[key]
		print("proxy ", key)
		for outcome in proxy.choice.outcomes:
			print("[", outcome.chance_expr, "] ", outcome.linked_event)
		for change in proxy.stat_changes:
			print("change [", change.chance_expr, "] ", change.stat_name, " ", change.change)
		for change in proxy.mod_changes:
			print("module [", change.chance_expr, "] ", change.stat_name, " ", change.change)
