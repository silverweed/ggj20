extends Node2D

const SIZE = 1024

export var speed: float = 50

onready var g1 = $Ground1
onready var g2 = $Ground2
onready var g3 = $Ground3

func _process(delta):
	g1.rect_position.x -= speed * delta
	g2.rect_position.x = g1.rect_position.x + SIZE
	g3.rect_position.x = g2.rect_position.x + SIZE
	
	if g1.rect_position.x < -SIZE:
		g1.rect_position.x += SIZE
	elif g2.rect_position.x < -SIZE:
		g2.rect_position.x += SIZE
	elif g3.rect_position.x < -SIZE:
		g3.rect_position.x += SIZE
