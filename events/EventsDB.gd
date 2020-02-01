class_name EventsDB
extends Node

	
var events = {}


func has(name: String) -> bool:
	return events.has(name)


func get(name: String) -> EventTypes.Event:
	return events[name]
	
	
func load_events(fname: String):
	var f = File.new()
	assert(f.file_exists(fname), "File " + fname + " not found!")
	f.open(fname, File.READ)
	var new_events = EventParser.parse_all_events(fname, f)
	f.close()
	print("[ok] loaded events from ", fname)
#	debug_print_events(events)
	for key in new_events:
		if events.has(key):
			print("[warning] overwriting duplicate event ", key)
		events[key] = new_events[key]
	


func debug_print_events(evts):
	for key in evts:
		var event: EventTypes.Event = events[key]
		print("event ", key)
		print("title ", event.title)
		print("---")
		print(event.description)
		print("---")
		for choice in event.choices:
			print(" > ", choice.description)
			for outcome in choice.outcomes:
				print("[", outcome.chance_expr, "] ", outcome.linked_event)
		for change in event.stat_changes:
			print("change [", change.chance_expr, "] ", change.stat_name, " ", change.change)
		
