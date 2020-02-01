extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var Hand_location = $"./Joint1/Joint2/Hand"
onready var target = $"target"
onready var base = $Leg_base

export var flipped = false

export var animation_offset = 0.0
onready var elapsed = 0
var started = false

func _ready():
	base.flipped = flipped
	base.local_scale = scale.x
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#target.global_position = get_global_mouse_position()
	elapsed += delta
	if !started && elapsed > animation_offset:
		$AnimationPlayer.play("walk_1")
	pass
