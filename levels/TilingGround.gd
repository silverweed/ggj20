extends Node2D

export var size: float = 1024
export var speed: float = 50

onready var g1 = $Ground1
onready var g2 = $Ground2
onready var g3 = $Ground3

func _process(delta):
	g1.rect_position.x -= speed * delta
	g2.rect_position.x = g1.rect_position.x + size
	g3.rect_position.x = g2.rect_position.x + size
	
	if g1.rect_position.x < -size:
		g1.rect_position.x += size
	elif g2.rect_position.x < -size:
		g2.rect_position.x += size
	elif g3.rect_position.x < -size:
		g3.rect_position.x += size
