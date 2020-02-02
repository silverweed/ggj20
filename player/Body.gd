class_name PlayerBody
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

class Module:
	var attach_point: Node2D
	var level: int
	var level_max: int
	
	func _init(atchpt: Node2D, lv: int, lvmax: int):
		self.attach_point = atchpt
		self.level = lv
		self.level_max = lvmax


var modules = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("Idle_1")
	globals.player = self
	globals.connect("stat_changed", self, "on_stat_changed")
	
	modules["mats"] = Module.new(
		$ModulesFg/ModuleMaterials, 0, 1)
	modules["housing"] = Module.new(
		$ModulesBg/ModuleHousing, 0, 3)
	modules["seeds"] = Module.new(
		$ModulesBg/ModuleSeeds, 0, 1)
	modules["weapon"] = Module.new(
		$ModulesFg/ModuleCannon, 0, 1)
		
		
func _exit_tree():
	globals.player = null


func on_stat_changed(name: String, value: int):
	if name != "fuel":
		return
	
	var ratio = float(globals.get_stat("fuel")) / globals.get_stat_max("fuel")
	var speed = lerp(0.4, 1.5, ratio)
	anim_player.playback_speed = speed
	for leg in legs:
		leg.get_node("AnimationPlayer").playback_speed = speed


func set_module_level(name: String, level: int):
	if !modules.has(name):
		print("module ", name, " does not exist.")
		return
	
	var mod = modules[name]
	
	if mod.level > 0:
		# Disable old sprite
		var sprite = mod.attach_point.get_node("Level" + str(mod.level))
		sprite.visible = false
	
	mod.level = clamp(level, 0, mod.level_max)
	mod.attach_point.visible = (mod.level > 0)
	
	if mod.level > 0:
		# Enable new sprite
		var sprite = mod.attach_point.get_node("Level" + str(mod.level))
		sprite.visible = true


func get_module_level(name: String) -> int:
	if !modules.has(name):
		print("module ", name, " does not exist.")
		return 0
	return modules[name].level
