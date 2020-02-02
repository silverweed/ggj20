class_name ChoiceContainer
extends VBoxContainer

const ENABLE_INPUT_AFTER_SECS = 0.1

signal choice_selected(n)

onready var choice_labels = [
	$Choice1,
	$Choice2,
	$Choice3,
	$Choice4
]

var displayed: int = 0
var selected: int = 0 setget set_selected


func _ready():
	set_process_input(false)
	$EnableInputTimer.wait_time = ENABLE_INPUT_AFTER_SECS
	
	
# choices: [String]
func show_choices(choices):
	
	$EnableInputTimer.connect("timeout", self, "set_process_input", [true], CONNECT_ONESHOT)
	$EnableInputTimer.start()
	
	displayed = min(4, len(choices))
	for i in range(0, displayed):
		choice_labels[i].text = choices[i]
		choice_labels[i].show()
	
	for i in range(displayed, 4):
		 choice_labels[i].hide()
	
	self.selected = 0
	show()


func set_selected(s: int):
	$AudioStreamPlayer.play()
	choice_labels[selected].selected = false
	selected = s
	choice_labels[s].selected = true
	

func _input(event):
	if event.is_action_pressed("ui_down"):
		self.selected = (selected + 1) % displayed
		
	elif event.is_action_pressed("ui_up"):
		self.selected = (selected - 1 + displayed) % displayed

	elif event.is_action_pressed("advance_text"):
		emit_signal("choice_selected", selected)
		set_process_input(false)
