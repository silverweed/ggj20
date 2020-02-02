extends Sprite

export var fade_t = 1.0
var t = 0

func _process(delta):
	t += delta
	modulate.a = lerp(0, 1, (fade_t - t) / fade_t)
