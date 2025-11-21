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
@onready var camera_2d: Camera2D = $Camera2D
@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animated_sprite_2d_2: AnimatedSprite2D = $AnimatedSprite2D2


enum states {IDLE, WALKING, ATTACKING, KNOCK, DEAD, SUMMON, STOP, CANNOT, THROW}

var state = states.IDLE

var health = 100

var heal = false
var deflect = true

var chase = false

var can_attack = true
var can_fuga = true
var execution = false
var execution1 = false
var execution2 = false
var execution3 = false
var execution4 = false
var execution5 = false
var summon = true
var execution7 = 1
var throwed = false

var bullet_path = preload("res://scenes/fuga.tscn")
var cleve_path = preload("res://scenes/cleve.tscn")
var wheel = preload("res://scenes/mwheel.tscn")
var mahoraga = preload("res://scenes/mahoraga.tscn")

var red = Color(3.0,1.0,1.0,1.0)
var white = Color8(255,255,255,255)

func change_state(new_state):
	state = new_state

func _physics_process(delta: float) -> void:
	#print(health)
	if execution7 == 1:
		label.text = "A"
	elif execution7 == 2:
		label.text = "S"
	elif execution7 == 3:
		label.text = "Z"
	elif execution7 == 4:
		label.text = "W"
	elif execution7 == 5:
		label.text = "D"
	elif execution7 == 6:
		label.text = "E"
	#global_position = target.global_position + Vector2(20,0)
	if state == states.DEAD:
		return
	match state:
		states.IDLE:
			idle()
		states.WALKING:
			walk()
		states.CANNOT:
			cannot()
	
	
	progress_bar.value = health
	
	if heal:
		if health < 100:
			health += 0.5
		elif health == 100:
			heal = false
	var stop = global_position.x - target.global_position.x
	if stop < 0 and not state == states.CANNOT:
		animated_sprite.flip_h = false
	elif stop > 0 and not state == states.CANNOT:
		animated_sprite.flip_h = true
	
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
	move_and_slide()
	if animated_sprite.flip_h == true:
		$Mwheel.position.x = -33.0
		collision_shape1.position.x = -15
	else:
		$Mwheel.position.x = 33.0
		collision_shape1.position.x = 15
func idle():
	if chase == false:
		animated_sprite.play("b_intro")
	elif chase:
		animated_sprite.play("intro")
func walk():
	#target.move = false
	animated_sprite.position.y = -5.0
	#velocity = Vector2.ZERO
	$CollisionShape2D.disabled = false
	if state == states.DEAD or state == states.KNOCK or state == states.CANNOT or state == states.THROW:
		return
	var direction = global_position.direction_to(target.global_position)
	var stop = global_position.x - target.global_position.x
	animated_sprite.play("walk")
	if is_on_floor():
		velocity.x = direction.x * speed
		if velocity.x > 0:
			if stop > -20:
				velocity.x = 0
		elif velocity.x < 0:
			if stop < 20:
				velocity.x = 0
	if velocity.x > 0 and can_attack:
		if stop < -200:
			choosing_attack()
			velocity.x = 0
	elif stop < -50 and health <= 20 and summon:
		velocity.x = 0
		animated_sprite.play("summon")
		change_state(states.SUMMON)
	elif velocity.x < 0 and can_attack:
		if stop > 200:
			choosing_attack()
			velocity.x = 0
	elif stop > 50 and health <= 30 and summon:
		velocity.x = 0
		animated_sprite.play("summon")
		change_state(states.SUMMON)
func choosing_attack():
	var ran = randi_range(1,4)
	if ran:
		if ran == 1:
			animated_sprite.play("cleve")
		elif can_fuga and health <= 20:
			animated_sprite.play("fuga")
		elif ran == 2:
			animated_sprite.play("cleve1")
		elif ran == 3:
			animated_sprite.play("cleve2")
		elif ran == 4:
			animated_sprite.play("cleve3")
		change_state(states.ATTACKING)
func _punch():
	if state == states.DEAD or state == states.KNOCK or state == states.CANNOT or state == states.THROW:
		return
	elif health > 0:
		animated_sprite.play("kick")
		change_state(states.ATTACKING)
func throw():
	# Throw AWAY from the player
	var throw_dir = sign(global_position.x - target.global_position.x)

	velocity.x = -1000      # Throw horizontally
	velocity.y = -1000              # Throw slightly upward for nice arc

	animated_sprite.play("hit_back 2") # your animation


	


func _on_area_2d_body_entered(_body: Node2D) -> void:
	var a = area_2d.get_overlapping_bodies()
	for area in a:
		if area.is_in_group("blue"):
			health -= 1
			if deflect:
				var bl = get_node("/root/Node2D/blue")
				animated_sprite.play("deflect")
				change_state(states.ATTACKING)
				bl._up()
		elif area.is_in_group("red"):
			health -= 1
		damage_received(10)
		_hit1()
	chase = true

func _on_area_2d_body_exited(_body: Node2D) -> void:
	pass
	#deflect = false
	
func hedied():
	animated_sprite.play("stand")
	velocity.x = 0
	chase = false
	change_state(states.STOP)

func cannot():
	global_position = target.global_position + Vector2(20,0)
	global_rotation = target.global_rotation
	animated_sprite.play("ground")
	animated_sprite.position.y = 5.0
	velocity = Vector2.ZERO
	collision_shape_2d.disabled = true
	$AnimatedSprite2D2.visible = true
	if target.animated_sprite_2d.flip_h == true:
		if target.velocity.x < 0.0:
			$AnimatedSprite2D2.play("smoke")
			$AnimatedSprite2D2.flip_h = true
			$AnimatedSprite2D2.position.x = 19.0
		animated_sprite.flip_h = false
	elif target.animated_sprite_2d.flip_h == false:
		if target.velocity.x > 0.0:
			$AnimatedSprite2D2.play("smoke")
			$AnimatedSprite2D2.flip_h = false
			$AnimatedSprite2D2.position.x = -19.0
		animated_sprite.flip_h = true


func _on_punch_box_body_entered(_body: Node2D ) -> void:
	_punch()

func _on_punch_box_body_exited(_body: Node2D) -> void:
	if not state == states.DEAD and not state == states.KNOCK and not state == states.CANNOT and not state == states.THROW :
		change_state(states.WALKING)

func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite.animation == "punch":
		target._hit()
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "kick":
		target.m_hit()
		animated_sprite.play("punch")
		$"punch sound".play()
	elif animated_sprite.animation == "punch":
		target.m_hit()
		animated_sprite.play("punch2")
		$"punch sound".play()
	elif animated_sprite.animation == "punch2":
		animated_sprite.play("kick")
		target._hit()
		$"punch sound".play()
	elif animated_sprite.animation == "hit_back":
		velocity.x = 0
		$"knock timer".start()
	elif animated_sprite.animation == "hit_back 2":
		change_state(states.WALKING)
		$HeadWheel.visible = true
		#change_state(states.THROW)
	elif animated_sprite.animation == "hit_back 3":
		change_state(states.WALKING)
	elif animated_sprite.animation == "hit_back 4":
		change_state(states.WALKING)
	elif animated_sprite.animation == "deflect":
		change_state(states.WALKING)
	elif animated_sprite.animation == "hit_back 1":
		target.animated_sprite_2d.play("dash")
		target.change_state(8)
		target.move = true
		$"knock 2".start()
	elif animated_sprite.animation == "intro":
		change_state(states.WALKING)
	elif animated_sprite.animation == "hit":
		$CollisionShape2D.disabled = true
	if animated_sprite.animation == "fuga":
		change_state(states.WALKING)
		can_fuga = false
		timer_3.start()
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
		can_attack = false
		change_state(states.WALKING)
		cleve_timer.start()
		for i in range (3):
			var cleve = cleve_path.instantiate()
			cleve.pos = $Node2D.global_position
			if animated_sprite.flip_h == true:
				cleve.speed = -1000
			else:
				cleve.speed = 1000 
			get_parent().add_child(cleve)
	elif animated_sprite.animation == "cleve1":
		can_attack = false
		change_state(states.WALKING)
		cleve_timer.start()
		for i in range (1):
			var cleve = cleve_path.instantiate()
			cleve.animation = 1
			cleve.pos = $Node2D.global_position
			if animated_sprite.flip_h == true:
				cleve.speed = -1000
			else:
				cleve.speed = 1000 
			get_parent().add_child(cleve)
	elif animated_sprite.animation == "cleve2":
		can_attack = false
		change_state(states.WALKING)
		cleve_timer.start()
		for i in range (1):
			var cleve = cleve_path.instantiate()
			cleve.animation = 2
			cleve.pos = $Node2D.global_position
			if animated_sprite.flip_h == true:
				cleve.speed = -1000
			else:
				cleve.speed = 1000 
			get_parent().add_child(cleve)
	elif animated_sprite.animation == "cleve3":
		can_attack = false
		change_state(states.WALKING)
		cleve_timer.start()
		for i in range (1):
			var cleve = cleve_path.instantiate()
			cleve.animation = 3
			cleve.pos = $Node2D.global_position
			if animated_sprite.flip_h == true:
				cleve.speed = -500
			else:
				cleve.speed = 500
			get_parent().add_child(cleve)
	elif animated_sprite.animation == "summon":
		var mwheel = wheel.instantiate()
		$"mahoraga summon".play()
		mwheel.pos = $Mwheel.global_position
		$Mwheel.position.y = -15.0
		cleve_timer.start()
		get_parent().add_child(mwheel)
		$wheel.start()
func _on_wheel_timeout() -> void:
	if state == states.CANNOT:
		return
	var maho = mahoraga.instantiate()
	maho.visible = true
	maho.pos = $Mwheel.global_position
	get_parent().add_child(maho)
	$Mwheel.position.y = -35.0
	summon = false
	if not state == states.DEAD:
		change_state(states.WALKING)
		
			
		
func damage_received(minus):
	var groups = area_2d.get_overlapping_bodies()
	for group in groups:
		if group.is_in_group("blue"):
			var blue = get_node("/root/Node2D/blue")
			blue.delete()
		elif group.is_in_group("red"):
			var red1 = get_node("/root/Node2D/red")
			red1.delete()
	if execution == false and execution1 == false and execution2 == false and execution3 == false and execution4 == false and execution5 == false:
		health -= minus
	if health <= 70 and execution7 == 1:
		if not $AnimationPlayer.current_animation == "RESET":
			$AnimationPlayer.play("execution")
			execution = true
			health = 70
	elif  health <= 60 and execution7 == 2:
		if not $AnimationPlayer.current_animation == "RESET":
			$AnimationPlayer.play("execution")
			health = 60
			execution1 = true
	elif  health <= 50 and execution7 == 3:
		if not $AnimationPlayer.current_animation == "RESET":
			$AnimationPlayer.play("execution")
			execution2 = true
			health = 50
	elif  health <= 30 and execution7 == 4:
		if not $AnimationPlayer.current_animation == "RESET":
			$AnimationPlayer.play("execution")
			execution3 = true
			health = 30
	elif  health <= 20 and execution7 == 5:
		if not $AnimationPlayer.current_animation == "RESET":
			$AnimationPlayer.play("execution")
			execution4 = true
			health = 20
	elif  health <= 10 and execution7 == 6:
		if not $AnimationPlayer.current_animation == "RESET":
			$AnimationPlayer.play("execution")
			execution5 = true
			health = 10
 	#punch_box.monitoring = false
	_hit1()
	$heal_tmer.start()
func _hit1():
	if label.text == "W" and execution3:
		animated_sprite.play("hit_1")
		animated_sprite.position.y = 2.0
		#execution7 = execution7 + 1
	#if health <= 0:
		#animated_sprite.position.y = 2.0
		#animated_sprite.play("hit")
		#timer_2.wait_time = 5
		#change_state(states.DEAD)
	animated_sprite.modulate = red
	timer_2.start()


func _on_timer_2_timeout() -> void:
	#punch_box.monitoring = true
	animated_sprite.modulate = white


func _on_timer_3_timeout() -> void:
	can_fuga = true


func _on_cleve_timer_timeout() -> void:
	can_attack = true


func _on_chase_range_body_entered(_body: Node2D) -> void:
	chase = true

func can_execution(type):
	if type == 1:
		var knock = global_position.direction_to(target.global_position)
		velocity.x = knock.x * -800
		animated_sprite.position.y = 2.0
		animated_sprite.play("hit_back")
		health -= 10
		execution7 = execution7 + 1
		change_state(states.KNOCK)
		cleve_timer.wait_time = 0.1
	if type == 2:
		var knock = global_position.direction_to(target.global_position)
		velocity.x = knock.x * -800
		animated_sprite.position.y = 2.0
		animated_sprite.play("hit_back 1")
		execution7 = execution7 + 1
		change_state(states.KNOCK)
	if type == 3:
		var knock = global_position.direction_to(target.global_position)
		animated_sprite.position.y = 2.0
		velocity.x = knock.x * -800
		animated_sprite.play("hit_back 3")
		change_state(states.KNOCK)
	if type == 4:
		var knock = global_position.direction_to(target.global_position)
		animated_sprite.position.y = 2.0
		velocity.x = knock.x * -800
		animated_sprite.play("hit_back 4")
		execution4 = false
		change_state(states.KNOCK)
		
		
		
	
		
func _on_heal_tmer_timeout() -> void:
	$AnimationPlayer.play("RESET")
	heal = true
	execution = false
	execution1 = false
	execution2 = false
	execution3 = false
	execution4 = false
func _on_knock_timer_timeout() -> void:
	if not state == states.DEAD:
		animated_sprite.position.y = -5.0
		change_state(states.WALKING)


func _on_knock_2_timeout() -> void:
	target.animated_sprite_2d.play("dash_1")
	target.animated_sprite_2d.position.x = 25.0
	target.animated_sprite_2d.position.y = -5.0
	change_state(states.CANNOT)
	target.change_state(8)
