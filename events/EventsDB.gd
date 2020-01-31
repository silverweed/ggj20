class_name EventsDB
extends Node

class Event:
	var title: String
	var description: String
	
var events = {}

func has(name: String) -> bool:
	return events.has(name)


func get(name: String) -> Event:
	return events[name]
	
	
func load_events(fname: String):
	var f = File.new()
	f.open(fname, File.READ)
	events = parse_all_events(f)
	f.close()
	
	
func parse_all_events(file: File): # -> Dict(name -> Event)
	var events = {}
	# Format:
	#   $event event_name
	#   $title Event Title (more than 1 word allowed)
	#   ---
	#   event description (multiline allowed)
	#   ---
	# ...repeats
	var cur_event: Event = null
	var cur_event_key = ""
	var started_desc = false
	var desc = ""
	while !file.eof_reached():
		var line = file.get_line().strip_edges()
		if line.begins_with("$event"):
			if cur_event != null:
				print("[syntax_error] previous event wasn't ended when read '$event'")
				break
			cur_event = Event.new()
			cur_event_key = line.trim_prefix("$event").strip_edges()
		elif line.begins_with("$title"):
			if cur_event == null:
				print("[syntax_error] found '$title' not belonging to any event")
				break
			cur_event.title = line.trim_prefix("$title").strip_edges()
		elif line.begins_with("---"):
			if started_desc:
				started_desc = false
				cur_event.description = desc
				events[cur_event_key] = cur_event
				cur_event = null
				desc = ""
				cur_event_key = ""
			else:
				started_desc = true
		elif started_desc:
			desc += line + "\n"
		
		
	if cur_event != null:
		print("[warning] Not all events were parsed correctly.")
	
	return events
