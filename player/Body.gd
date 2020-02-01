extends Node2D

onready var globals = $"/root/Globals"
onready var anim_player = $AnimationPlayer
onready var legs = [
	$IK_leg1,
	$IK_leg2,
	$IK_leg3, 
	$IK_leg4,
	$IK_leg5
]

onready var modules = {
	"materials": $ModulesFg/ModuleAttachPointFg1,
	"inhabitants": $ModulesBg/ModuleAttachPointBg2,
	"seeds": $ModulesBg/ModuleAttachPointBg3,
	"cannon": $ModulesFg/ModuleAttachPointFg2
}

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("Idle_1")
	globals.connect("stat_changed", self, "on_stat_changed")


func on_stat_changed(name: String, value: int):
	if name != "fuel":
		return
	
	var ratio = float(globals.get_stat("fuel")) / globals.get_stat_max("fuel")
	var speed = lerp(0.4, 1.5, ratio)
	anim_player.playback_speed = speed
	for leg in legs:
		leg.get_node("AnimationPlayer").playback_speed = speed


func set_module_active(name: String, active: bool):
	if !modules.has(name):
		print("module ", name, " does not exist.")
		return
	modules[name].visible = active
