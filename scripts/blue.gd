extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var hit: Area2D = $hit

var pos:Vector2
var dir:float
var speed = 555

func _ready() -> void:
	global_position=pos
	timer.start()
func _physics_process(_delta: float) -> void:
	var dis = global_position.distance_to(pos)
	velocity=Vector2(speed,0).rotated(dir)
	if dis > 500:
		queue_free()
		print("deleted")
	move_and_slide()
	var lap = hit.get_overlapping_bodies()
	for area in lap:
		if area.is_in_group("hit"):
			print("area")
	
	


func _on_timer_timeout() -> void:
	queue_free()
