class_name ScreenShakeSystem
extends Node

export (NodePath) var camera_path

const SHAKE_X = 1
const SHAKE_Y = 1 << 1

var noise : OpenSimplexNoise
var camera : Camera2D

var shake_t = 0
var shake_duration = 0
var shake_strength = 1
var flags = 0

func _ready():
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20
	noise.persistence = 08
	camera = get_node(camera_path)
	assert(camera)
	$"/root/Globals".screenshake_sys = self
	

func _exit_tree():
	$"/root/Globals".screenshake_sys = null


func _process(delta):
	if shake_duration == 0:
		set_process(false)
		return
		
	if shake_t < shake_duration:
		shake_t += delta
		if shake_t > shake_duration:
			camera.offset = Vector2()
			set_process(false)
			return
			
	var strength = lerp(shake_strength, 0, shake_t / shake_duration)
	
	var x = noise.get_noise_2d(camera.offset.x + 1, camera.offset.y + 1)
	var y = noise.get_noise_2d(camera.offset.y + 1, camera.offset.x + 1)
	if flags & SHAKE_X:
		camera.offset.x = strength * x
	if flags & SHAKE_Y:
		camera.offset.y = strength * y
	
	
	
func screenshake(strength : float, duration : float,
				enable_x = true, enable_y = true, 
				starting_x_off = 0, starting_y_off = 0):
	shake_t = 0
	shake_duration = duration
	shake_strength = strength
	flags = 0
	if enable_x:
		flags |= SHAKE_X
		camera.offset.x = starting_x_off
	if enable_y:
		flags |= SHAKE_Y
		camera.offset.y = starting_y_off
	set_process(true)
