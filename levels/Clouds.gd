extends Node2D

const CloudTextures = [
	preload("res://assets/T_env_cloud_1.png"),
	preload("res://assets/T_env_cloud_2.png"),
	preload("res://assets/T_env_cloud_3.png"),
	preload("res://assets/T_env_cloud_4.png"),
	preload("res://assets/T_env_cloud_5.png")
]

const MAX_SPAWN_X = 3000
const DESPAWN_X = 1500
const N_CLOUDS = 12

var clouds = []
var velocities = []

func _ready():
	for i in range(N_CLOUDS):
		spawn_cloud_at_random_pos()
		

func _process(delta):
	for i in range(clouds.size()):
		clouds[i].position.x += velocities[i] * delta
		if clouds[i].position.x < -DESPAWN_X:
			clouds[i].position.x = rand_range(MAX_SPAWN_X, MAX_SPAWN_X * 4)
			
	
func spawn_cloud_at_random_pos():
	var x = rand_range(0, MAX_SPAWN_X * 4)
	var y = rand_range(-700, 400)
	var cloud = Sprite.new()
	var sx = rand_range(1, 3)
	var sy = sx * rand_range(0.8, 1.3)
	
	cloud.texture = CloudTextures[randi() % len(CloudTextures)]
	cloud.position = Vector2(x, y)
	cloud.scale = Vector2(sx, sy)
	cloud.modulate = calc_fade_color()
	
	clouds.append(cloud)
	velocities.append(-rand_range(30, 100))
	add_child(cloud)
	
	
func calc_fade_color() -> Color:
	var a = lerp(0.6, 1, 1.0 * clouds.size() / N_CLOUDS)
	return Color(a, a, min(1, a*1.1), rand_range(0.2, 0.6))

