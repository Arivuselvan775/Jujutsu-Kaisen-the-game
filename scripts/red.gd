extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var timer_2: Timer = $Timer2
@onready var target = get_node("/root/Node2D/CharacterBody2D")

var pos:Vector2
var dir:float
var speed = 0.0
var start = false

func _ready() -> void:
	$red.play()
	global_position=pos
	timer.start()
func _physics_process(_delta: float) -> void:
	if target.state == 6:
		hallow_purple()
	var dis = global_position.distance_to(pos)
	velocity.x = speed
	if dis > 1500 and velocity.x:
		queue_free()
	if dis > 300 and velocity.y and start == false:
		timer_2.start()
		target.animation_player.play("final execution")
		target.final = true
		velocity.y = 0
		$move.start()
		target.can_purple = true
	if start:
		$CollisionShape2D.set_deferred("disabled",true)
		var move = get_node("/root/Node2D/blue")
		var direction = global_position.direction_to(move.global_position)
		velocity = direction * 500
	move_and_slide()
	
	


func _on_timer_timeout() -> void:
	if velocity.x and start == false:
		#queue_free()
		pass


func _on_timer_2_timeout() -> void:
	if velocity.x:
		queue_free()
	pass


func hallow_purple():
	start = true


func _on_purple_trigger_area_entered(_area: Area2D) -> void:
	target.call_deferred("fin")
	queue_free()

func delete():
	$delete.start()


func _on_delete_timeout() -> void:
	if target.can_purple == false:
		queue_free()
