extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer_2: Timer = $Timer2

var pos:Vector2
var dir:float
var speed= 555 

func _ready() -> void:
	global_position=pos
	timer.start()
func _physics_process(_delta: float) -> void:
	var dis = global_position.distance_to(pos)
	velocity.x = speed
	if dis > 500 and velocity.x:
		queue_free()
		print("red deleted")
	if dis >= 250 and velocity.y:
		timer_2.start()
		velocity.y = 0
	move_and_slide()
	
	


func _on_timer_timeout() -> void:
	if velocity.x:
		queue_free()


func _on_timer_2_timeout() -> void:
		queue_free()
