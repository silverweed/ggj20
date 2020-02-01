class_name EventTypes

class Event:
	var title: String
	var description: String
	var choices = [] # [Choice]
	

class Event_Choice:
	var description: String
	var outcomes = [] # [Outcome]
	

class Event_Outcome:
	# An expression like "50 + speed * 2 - luck"
	# Empty means "whatever % remains after subtracting all others"
	var chance_expr: String
	var linked_event: String
