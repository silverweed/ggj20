extends VBoxContainer

const ICONS = {
	"combat": preload("res://ui/textures/Event_Icons_T_event_combat.png"),
	"heart": preload("res://ui/textures/Event_Icons_T_event_heart.png"),
	"human": preload("res://ui/textures/Event_Icons_T_event_human.png"),
	"repair": preload("res://ui/textures/Event_Icons_T_event_repair.png"),
	"upgrade": preload("res://ui/textures/Event_Icons_T_event_upgrade.png")
}

onready var texture = $TextureRect

func _ready():
	$"/root/Globals".connect("event_started", self, "on_event_started")
	
	
func on_event_started(event: EventTypes.Event, _stats_change, _mods_change):
	texture.texture = ICONS[category(event)]
	
	
func category(event: EventTypes.Event) -> String:
	return ICONS.keys()[randi() % len(ICONS.keys())] # TODO
