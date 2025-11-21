extends Camera2D

var shake_amount: float = 0.0
var shake_decay: float = 5.0   # how fast shake ends
var max_offset: float = 10.0   # maximum shake distance

var original_offset := Vector2.ZERO

func _ready():
	original_offset = offset

func _process(delta):
	if shake_amount > 0:
		# Generate random shake
		offset = original_offset + Vector2(
			randf_range(-max_offset, max_offset),
			randf_range(-max_offset, max_offset)
		) * shake_amount
		
		# Reduce shake over time
		shake_amount = lerp(shake_amount, 0.0, delta * shake_decay)
	else:
		offset = original_offset

func shake(intensity: float):
	shake_amount = intensity
