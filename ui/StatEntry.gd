extends Control

export var stat_name: String

onready var globals = $"/root/Globals"
onready var stat_value = $HBoxContainer/StatValue

func _ready():
	assert(stat_name.length() > 0, "Empty stat name on StatEntry!")
	$HBoxContainer/StatName.text = stat_name + ":"

	update_stat_value()

	globals.connect("stat_changed", self, "on_stat_changed")
	
	
func on_stat_changed(name: String, value: int):
	if name == stat_name:
		update_stat_value()
		
		
func update_stat_value():
	var stats = globals.stats_cur
	var mstats = globals.stats_max
	assert(stats.has(stat_name), "No stat named " + stat_name + "!")
	stat_value.text = str(stats[stat_name]) + " / " + str(mstats[stat_name])
