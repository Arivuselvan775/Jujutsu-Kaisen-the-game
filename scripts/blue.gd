extends CharacterBody2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var target = get_node("/root/Node2D/enemy")
@onready var target1 = get_node("/root/Node2D/CharacterBody2D")

var pos:Vector2
var dir:float
var speed = 555
var up = true
var start = false

func _ready() -> void:
	$AudioStreamPlayer2D.play()
	global_position=pos
	timer.start()
func _physics_process(_delta: float) -> void:
	# ... (Your existing logic) ...
	if target1.state == 6:
		hallow_purple()
	
	var dis = global_position.distance_to(pos)
	
	if up:
		velocity.x = speed
	if up == false and start == false:
		var range1 = global_position.distance_to(target.global_position)
		if range1 >= 320:
			velocity.y = 0
			# Added an instance check to prevent crashing if target doesn't exist
			if is_instance_valid(target) and target.health <= 10:
				target1.can_red = true
		else:
			velocity.y = -555
		velocity.x = 0
	
	if dis > 800 and up == true:
		queue_free()

	# --- THE FIX ---
	move_and_slide()
	
	# check if we hit a wall (CharacterBody2D updates this flag after moving)
	if is_on_wall():
		queue_free()
	# ----------------
	
	if start:
		$CollisionShape2D.set_deferred("disabled", true)
		var move = get_node("/root/Node2D/red")
		if is_instance_valid(move): # Safety check
			var direction = global_position.direction_to(move.global_position)
			velocity = direction * 1000

func _up():
	up = false
	
func _on_timer_timeout() -> void:
	if up:
		queue_free()
func hallow_purple():
	start = true


func _on_purple_trigger_area_entered(_area: Area2D) -> void:
	velocity.x = 0
	queue_free()

func delete():
	$delete.start()


func _on_delete_timeout() -> void:
	if up:
		queue_free()
