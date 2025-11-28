extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var target = get_node("/root/Node2D/CharacterBody2D")

var pos:Vector2
var dir:float
var speed = 0.0
var start = false

func _ready() -> void:
	global_position=pos
func _physics_process(_delta: float) -> void:
	if target.state == 6:
		hallow_purple()
	var dis = global_position.distance_to(pos)
	if dis > 350 and velocity.y and start == false:
		velocity.y = 0
		target.can_red = true
	if start:
		var move = get_node("/root/Node2D/up red")
		var direction = global_position.direction_to(move.global_position)
		velocity = direction * 250
	move_and_slide()

func hallow_purple():
	start = true


func _on_purple_trigger_area_entered(_area: Area2D) -> void:
	velocity.x = 0
	target.call_deferred("fin")
	queue_free()
