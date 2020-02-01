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
	events = EventParser.parse_all_events(f)
	f.close()
	debug_print_events(events)
	


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
		
