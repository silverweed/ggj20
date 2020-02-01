extends Control

export var stat_name: String

onready var globals = $"/root/Globals"
onready var stat_value = $HBoxContainer/StatValue

func _ready():
	assert(stat_name.length() > 0, "Empty stat name on StatEntry!")
	$HBoxContainer/StatName.text = stat_name.capitalize() + ":"

	update_stat_value()

	globals.connect("stat_changed", self, "on_stat_changed")
	
	
func on_stat_changed(name: String, value: int):
	if name == stat_name:
		update_stat_value()
		
		
func update_stat_value():
	stat_value.text = str(globals.get_stat(stat_name)) + \
			" / " + str(globals.get_stat_max(stat_name))
