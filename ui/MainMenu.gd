extends Control

onready var underline = $Underline

var disable_t = 0
var disabled = false

func _ready():
	$AnimationPlayer.play("Blink")
	set_process(false)
	

func _process(delta):
	disable_t -= delta
	if disable_t <= 0:
		disabled = false
		set_process(false)
		set_process_input(true)
		
	
func _input(event):
	if event.is_action_pressed("ui_cancel") and $Credits.visible:
		$Credits.hide()
		disable_for(0.4)
		
	
func _on_Quit_pressed():
	if !disabled:
		get_tree().quit()


func _on_Play_pressed():
	if !disabled:
		get_tree().change_scene("res://levels/Level.tscn")


func _on_Credits_pressed():
	if !disabled:
		$Credits.show()


func move_underline(node: Control):
	$AudioStreamPlayer.play()
	underline.rect_global_position.y = node.rect_global_position.y + 140


func _on_Play_mouse_entered():
	move_underline($VBoxContainer2/VBoxContainer/Play)
	

func _on_Credits_mouse_entered():
	move_underline($VBoxContainer2/VBoxContainer/Credits)


func _on_Quit_mouse_entered():
	move_underline($VBoxContainer2/VBoxContainer/Quit)
	

func disable_for(secs: float):
	disable_t = secs
	disabled = true
	set_process(true)
	set_process_input(false)
