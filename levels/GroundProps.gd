extends Node2D

const TreeTextures = [
	preload("res://assets/T_env_tree_1.png"),
	preload("res://assets/T_env_tree_2.png"),
	preload("res://assets/T_env_tree_3.png"),
]

const MAX_SPAWN_X = 3000
const DESPAWN_X = 1500
const N_TREES = 12

export var speed_bg = 100
export var speed_fg = 120

var trees = []
var velocities = []

func _ready():
#	Engine.time_scale = 10
	for i in range(N_TREES):
		spawn_tree_at_random_pos()
		

func _process(delta):
	for i in range(trees.size()):
		var tree = trees[i]
		tree.position.x += velocities[i] * delta
		if tree.position.x < -DESPAWN_X:
			tree.position.x = rand_range(MAX_SPAWN_X, MAX_SPAWN_X * 4)
			tree.z_index = 50 * (randi() % 2 - 1)
			velocities[i] = -speed_bg if tree.z_index < 0 else -speed_fg
			
	
func spawn_tree_at_random_pos():
	var x = rand_range(0, MAX_SPAWN_X * 1.5)
	var y = rand_range(-5, 5)
	var tree = Sprite.new()
	var sx = rand_range(0.8, 1.3)
	var sy = sx
	
	tree.texture = TreeTextures[randi() % len(TreeTextures)]
	tree.position = Vector2(x, y)
	tree.scale = Vector2(sx, sy)
	tree.z_index = 800 * (2 * (randi() % 2) - 1)
	if tree.z_index >= 0:
		tree.position.y -= 10
	
	trees.append(tree)
	velocities.append(-speed_bg if tree.z_index < 0 else -speed_fg)
	add_child(tree)

