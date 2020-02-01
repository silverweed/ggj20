extends Node2D


onready var globals = $"/root/Globals"
onready var target = $"target"
onready var base = $Leg_base

export var flipped = false

export var animation_offset = 0.0

func _ready():
	base.flipped = flipped
	base.local_scale = scale.x
	$AnimationPlayer.play("walk_1")
	$AnimationPlayer.seek(animation_offset)


func screenshake():
	globals.do_screenshake()
