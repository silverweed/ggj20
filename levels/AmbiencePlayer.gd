extends AudioStreamPlayer

const AMB_SOUNDS = {
	"bird": [
		preload("res://sfx/AMB_Bird_01.wav"),
		preload("res://sfx/AMB_Bird_02.wav"),
		preload("res://sfx/AMB_Bird_03.wav"),
	],
	"dog": [
		preload("res://sfx/AMB_Dog_01.wav"),
	],
	"rain": [
		preload("res://sfx/AMB_Rain_01.wav"),
		preload("res://sfx/AMB_Rain_02.wav"),
	],
	"rocks": [
		preload("res://sfx/AMB_Rocks_01.wav"),
		preload("res://sfx/AMB_Rocks_02.wav"),
	],
	"water": [
		preload("res://sfx/AMB_Water_01.wav"),
		preload("res://sfx/AMB_Water_02.wav"),
		preload("res://sfx/AMB_Water_03.wav"),
	],
	"wind": [
		preload("res://sfx/AMB_Wind_01.wav"),
		preload("res://sfx/AMB_Wind_02.wav"),
	]
}

var all_sounds = []


func _ready():
	for sounds in AMB_SOUNDS.values():
		for s in sounds: all_sounds.append(s)
	
	play_random_ambience()
	connect("finished", self, "play_random_ambience")
		
		
func play_ambience(type: String):
	if !AMB_SOUNDS.has(type):
		print("[error] inexisting ambience type ", type)
		return
	var sounds = AMB_SOUNDS[type]
	var sound = sounds[randi() % len(sounds)]
	stream = sound
	play()


func play_random_ambience():
	stream = all_sounds[randi() % len(all_sounds)]
	play()
