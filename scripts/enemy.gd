extends CharacterBody2D

var speed = 150
@onready var target = get_node("/root/Node2D/CharacterBody2D")
@onready var damage: AnimatedSprite2D = target.get_node("AnimatedSprite2D")
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var area_2d: Area2D = $Area2D
@onready var collision_shape1: CollisionShape2D = $"punch box/CollisionShape2D"
@onready var punch_box: Area2D = $"punch box"
@onready var timer_2: Timer = $Timer2
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var timer_3: Timer = $Timer3
@onready var cleve_timer: Timer = $"cleve timer"
@onready var progress_bar: ProgressBar = $ProgressBar

var health = 100

var hit = false
var punch = false
var hit1 = false
var timer3 = true
var cleve1 = true
var b = false
var died = false
var summon = true
var stay = false
var one = true
var heal = false
var knock1 = false

var chase = false

var bullet_path = preload("res://scenes/fuga.tscn")
var cleve_path = preload("res://scenes/cleve.tscn")
var wheel = preload("res://scenes/mwheel.tscn")
var mahoraga = preload("res://scenes/mahoraga.tscn")

var red = Color(3.0,1.0,1.0,1.0)
var white = Color8(255,255,255,255)


func _physics_process(delta: float) -> void:
	progress_bar.value = health
	print (knock1)
	if hit or punch or hit1 or died or stay or knock1:
		move_and_slide()
		return
	if heal:
		if health < 100:
			health += 0.5
		elif health == 100:
			heal = false
	var direction = global_position.direction_to(target.global_position)
	var stop = global_position.x - target.global_position.x
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
	elif is_on_floor() and chase:
		velocity = direction * speed
		if velocity.x > 0:
			if stop > -20:
				velocity.x = 0
			animated_sprite.flip_h = false
		elif velocity.x < 0:
			if stop < 20:
				velocity.x = 0
			animated_sprite.flip_h = true
	if velocity.x > 0:
		if stop < -200 and timer3 and health <= 50:
			velocity.x = 0
			animated_sprite.play("fuga")
			$fuga.play()
		elif stop < -200 and cleve1:
			velocity.x = 0
			animated_sprite.play("cleve")
		elif stop < -200 and cleve1 == false and summon and health <= 30 and one:
			velocity.x = 0
			animated_sprite.play("summon")
		elif stop < -20:
			animated_sprite.play("walk")
	elif velocity.x < 0:
		if stop > 200 and timer3 and health <= 50:
			velocity.x = 0
			animated_sprite.play("fuga")
			$fuga.play()
		elif stop > 200 and cleve1:
			velocity.x = 0
			animated_sprite.play("cleve")
		elif stop > 200 and cleve1 == false and summon and health <= 30 and one:
			velocity.x = 0
			animated_sprite.play("summon")
		elif stop > 20:
			animated_sprite.play("walk")
	elif chase == false:
		animated_sprite.play("stand")
	move_and_slide()
	if animated_sprite.flip_h == true:
		$Mwheel.position.x = -33.0
		collision_shape1.position.x = -15
	else:
		$Mwheel.position.x = 33.0
		collision_shape1.position.x = 15
func _punch():
	if health > 0:
		punch = true
		velocity.x = 0
		if punch == true:
			animated_sprite.play("kick")

	


func _on_area_2d_body_entered(_body: Node2D) -> void: 
	damage_received(10)
	_hit1()
	chase = true
	
func hedied():
	died = true
	animated_sprite.play("stand")
	velocity.x = 0
	
	


func _on_punch_box_body_entered(_body: Node2D ) -> void:
	_punch()

func _on_punch_box_body_exited(_body: Node2D) -> void:
	punch = false

func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite.animation == "punch" and punch == true:
		target._hit()
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "kick" and punch == true:
		target.m_hit()
		animated_sprite.play("punch")
		$"punch sound".play()
	elif animated_sprite.animation == "punch" and punch == true:
		target.m_hit()
		animated_sprite.play("punch2")
		$"punch sound".play()
	elif animated_sprite.animation == "punch2":
		animated_sprite.play("kick")
		target._hit()
		$"punch sound".play()
	elif animated_sprite.animation == "hit_back":
		animated_sprite.position.y = -1.0
		knock1 = false
	if animated_sprite.animation == "fuga":
		timer_3.start()
		timer3 = false
		var bullet = bullet_path.instantiate()
		bullet.pos = $Node2D.global_position  # Starting position
		var spr = bullet.get_node("Sprite2D")
		var spr1 = bullet.get_node("Sprite2D2")
		
		if animated_sprite.flip_h == true:
			bullet.speed = -1000
			spr.flip_h = true
			spr1.flip_h = false
			spr1.position.x = -28
		else:
			spr.flip_h = false
			spr1.flip_h = true
			spr1.position.x = 28
			bullet.speed = 1000
		get_parent().add_child(bullet)
	elif animated_sprite.animation == "cleve":
		cleve_timer.start()
		cleve1 = false
		for i in range (3):
			var cleve = cleve_path.instantiate()
			cleve.pos = $Node2D.global_position
			if animated_sprite.flip_h == true:
				cleve.speed = -1000
			else:
				cleve.speed = 1000 
			get_parent().add_child(cleve)
	elif animated_sprite.animation == "summon":
		var mwheel = wheel.instantiate()
		$"mahoraga summon".play()
		mwheel.pos = $Mwheel.global_position
		$Mwheel.position.y = -15.0
		summon = false
		cleve_timer.start()
		get_parent().add_child(mwheel)
		stay = true
		$wheel.start()
func _on_wheel_timeout() -> void:
	var maho = mahoraga.instantiate()
	maho.visible = true
	maho.pos = $Mwheel.global_position
	get_parent().add_child(maho)
	$Mwheel.position.y = -35.0
	one = false
	stay = false
		
			
		
		
func damage_received(minus):
	health -= minus
	#punch_box.monitoring = false
	_hit1()
	$heal_tmer.start()
func _hit1():
	hit1 = true
	if health <= 0:
		animated_sprite.position.y = 2.0
		animated_sprite.play("hit")
		timer_2.wait_time = 5
	animated_sprite.modulate = red
	timer_2.start()


func _on_timer_2_timeout() -> void:
	#punch_box.monitoring = true
	hit1 = false
	animated_sprite.modulate = white
	if health <= 0:
		queue_free()


func _on_timer_3_timeout() -> void:
	timer3 = true


func _on_cleve_timer_timeout() -> void:
	cleve1 = true
	summon = true


func _on_chase_range_body_entered(_body: Node2D) -> void:
	chase = true



func _on_heal_tmer_timeout() -> void:
	heal = true
func hit_back():
	var knock = global_position.direction_to(target.global_position)
	if health < 40:
		velocity.x = knock.x * -600
		print(velocity.x)
		knock1 = true
		animated_sprite.position.y = 2.0
		animated_sprite.play("hit_back")
