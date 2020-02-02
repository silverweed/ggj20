extends Control

func _ready():
	$EventUI.connect("choice_selected", self, "play_confirm")
	$"/root/Globals".connect("event_started", self, "play_evt_started")


func play_confirm(_1, _2):
	$Sfx_UI_Confirm.play()
	

func play_evt_started(_1, _2, _3):
	$Sfx_New_Event.play()
