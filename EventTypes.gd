class_name EventTypes

class Event:
	var title: String
	var icon: String
	var description: String
	var choices = []      # [Choice]
	var stat_changes = [] # [Stat_Change]
	var mod_changes = []  # [Stat_Change]


class Proxy_Event:
	var choice: Event_Choice
	var stat_changes = []
	var mod_changes = []
	
	
class Stat_Change:
	var chance_expr: String
	var stat_name: String
	var change: int
	
	
class Event_Choice:
	var chance_expr: String
	var description: String
	var outcomes = [] # [Outcome]
	

class Event_Outcome:
	# An expression like "50 + speed * 2 - luck"
	# Empty means "whatever % remains after subtracting all others"
	var chance_expr: String
	var linked_event: String
