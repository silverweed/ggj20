extends VBoxContainer

const ICONS = {
	"combat": preload("res://ui/textures/Event_Icons_T_event_combat.png"),
	"heart": preload("res://ui/textures/Event_Icons_T_event_heart.png"),
	"human": preload("res://ui/textures/Event_Icons_T_event_human.png"),
	"repair": preload("res://ui/textures/Event_Icons_T_event_repair.png"),
	"upgrade": preload("res://ui/textures/Event_Icons_T_event_upgrade.png"),
	"generic": preload("res://ui/textures/Event_Icons_T_event_generic.png")
}

onready var texture = $TextureRect
onready var title_label = $Title

func _ready():
	$"/root/Globals".connect("event_started", self, "on_event_started")
	
	
func on_event_started(event: EventTypes.Event, _stats_change, _mods_change):
	texture.texture = ICONS[category(event)]
	title_label.text = event.title
	
	
func category(event: EventTypes.Event) -> String:
	return event.icon if ICONS.has(event.icon) else "generic"
