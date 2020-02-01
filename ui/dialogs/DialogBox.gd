class_name DialogBox
extends Control

signal advance
signal all_displayed
signal single_displayed

export var chars_per_second = 50
export var hide_on_finish = false
var automatic_advance = false setget set_automatic_advance
var hang_time_after_last = 0
var manual_advance_is_locked = false
var differentiate_separators_cadence = true
# If false, calling display_all(["a", "b", "c"]) will result in
# the full "abc" string displayed.
var erase_previous_text_upon_display = true
# If automatic_advance is true and this is > 0, wait for this time
# before the next text.
var force_single_advance_t = 0

var text_cursor = 0
var waiting = false
var interruptible_wait_timer = Timer.new()
var is_killed = false

onready var label = $Panel/RichTextLabel
onready var panel = $Panel
onready var ahead = $Panel/GoAhead

func _ready():
	$AnimationPlayer.play("ahead")
	interruptible_wait_timer.connect("timeout", self, "emit_signal", ["advance"])
	add_child(interruptible_wait_timer)
	
	
func display(text):
	if erase_previous_text_upon_display:
		text_cursor = 0
	waiting = false
	ahead.hide()
	while !is_killed and text_cursor < len(text):
		# Eat bbcode
		while text[text_cursor] == '[':
			while text[text_cursor] != ']':
				text_cursor += 1
			text_cursor += 1
			if text_cursor >= len(text):
				break
		
		label.bbcode_text = text.substr(0, text_cursor)
		
		var time = 1.0 / chars_per_second
		if text_cursor > 0:
			time *= char_mul(text[text_cursor-1])
		
		yield(get_tree().create_timer(time), "timeout")
		
		text_cursor += 1
	label.bbcode_text = text
	waiting = true
	if !automatic_advance:
		ahead.show()
	emit_signal("single_displayed")
	
	
func display_all(ts):
	var texts = ts
	text_cursor = 0
	show()
	for t in texts:
		if is_killed:
			return
		display(t)
		if automatic_advance:
			yield(self, "single_displayed")
			var advance_t
			if force_single_advance_t > 0:
				advance_t = force_single_advance_t
			else:
				# Note: this formula was pulled out of my ass
				advance_t = lerp(1, 4, len(t) / 180.0)
			create_interruptible_wait(advance_t)
		yield(self, "advance")
	
	if is_killed:
		return
	waiting = true
	if automatic_advance:
		create_interruptible_wait(hang_time_after_last)
		yield(self, "advance")
		
	if hide_on_finish: hide()
	label.bbcode_text = ""
	emit_signal("all_displayed")
	
	
func create_interruptible_wait(t):
	interruptible_wait_timer.wait_time = t
	interruptible_wait_timer.start()
	

func kill():
	is_killed = true
	
	
# XXX: this code is horrible
func _input(event):
	if !manual_advance_is_locked and event.is_action_pressed("advance_text"):
		if waiting:
			emit_signal("advance")
			interruptible_wait_timer.stop()
		else:
			text_cursor = 9999999


func char_mul(c):
	if !differentiate_separators_cadence:
		return 1
		
	match c:
		'\n': return 10
		'.', '!', '?': return 15
		',', ';', ':': return 7
		'-': return 10
		_: return 1
		
		
func set_transparent(b):
	$Panel.self_modulate.a = 0 if b else 1
	

func set_automatic_advance(a):
	automatic_advance = a
	if !a:
		interruptible_wait_timer.stop()
	
	
func set_text_color(col):
	$Panel/RichTextLabel.self_modulate = col
