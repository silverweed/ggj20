extends Node2D

const FOOTSTEPS = [
	preload("res://sfx/sfx_locomotion_footsteps-001.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-002.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-003.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-004.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-005.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-006.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-007.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-008.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-009.wav"),
	preload("res://sfx/sfx_locomotion_footsteps-010.wav"),
]

var rand_sfx_idx = []

onready var globals = $"/root/Globals"
onready var target = $"target"
onready var base = $Leg_base
onready var audio_player1 = $AudioStreamPlayer
onready var audio_player2 = $AudioStreamPlayer2

export var flipped = false

export var animation_offset = 0.0

func _ready():
	base.flipped = flipped
	base.local_scale = scale.x
	$AnimationPlayer.play("walk_1")
	$AnimationPlayer.seek(animation_offset)
	
	for i in range(0, len(FOOTSTEPS)):
		rand_sfx_idx.append(i)


func screenshake():
	globals.do_screenshake()


func play_sfx():
	rand_sfx_idx.shuffle()
	audio_player1.stream = FOOTSTEPS[rand_sfx_idx[0]]
	audio_player2.stream = FOOTSTEPS[rand_sfx_idx[1]]
	audio_player1.play()
	audio_player2.play()
