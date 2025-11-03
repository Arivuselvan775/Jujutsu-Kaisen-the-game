extends CharacterBody2D

# These run only when the node is ready in the scene tree
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var timer2: Timer = $Timer2
@onready var enemy = get_node("/root/Node2D/enemy")
@onready var dead: Timer = $dead
@onready var label: Label = $Label
@onready var red: AudioStreamPlayer2D = $red
@onready var red_starting: AudioStreamPlayer2D = $"red starting"
@onready var collision_shape_2d: CollisionShape2D = $AnimatedSprite2D/hitbox/CollisionShape2D
@onready var timer_3: Timer = $Timer3
@onready var hitbox: Area2D = $AnimatedSprite2D/hitbox
@onready var progress_bar: TextureProgressBar = get_node("/root/Node2D/CanvasLayer/ProgressBar")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sred_timer: Timer = $"sred timer"



# Constants (unchangeable values)
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
#health 
var health = 100

# Preload bullet scene (so it’s ready in memory)
var bullet_path = preload("res://scenes/blue.tscn")
var bullet_path1 = preload("res://scenes/red.tscn")

enum states {IDLE, WALKING, ATTACKING, JUMPING ,DIED}

var state = states.IDLE


func _physics_process(delta: float) -> void:
	progress_bar.value = health
	match state:
		states.IDLE:
			idle()
		states.WALKING:
			walk()
		states.ATTACKING:
			attack()
		states.DIED:
			died()
		states.JUMPING:
			jumping()
	if state == states.DIED:
		get_gravity()
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("jump")

	# Movement input
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	if velocity.x < 0:
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0:
		animated_sprite_2d.flip_h = false
	if animated_sprite_2d.flip_h == true:
		collision_shape_2d.position.x = -15.5
	else:
		collision_shape_2d.position.x = 15.5

	
		
func change_state(new_state):
	state = new_state
func idle():
	animated_sprite_2d.play("default")
	if Input.get_axis("ui_left" , "ui_right"):
		animated_sprite_2d.play("walk")
		change_state(states.WALKING)
	elif Input.is_action_just_pressed("ui_accept"):
		change_state(states.JUMPING)
	elif Input.is_action_just_pressed("blue"):
		animated_sprite_2d.play("blue")
		timer.start()
		change_state(states.ATTACKING)
		$"blue starting".play()
	elif Input.is_action_just_pressed("red"):
		animated_sprite_2d.play("red")
		timer2.start()
		red_starting.play()
		change_state(states.ATTACKING)
	elif Input.is_action_pressed("attack1"):
		animated_sprite_2d.play("punch")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("kick"):
		animated_sprite_2d.play("kick")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("sred"):
		animated_sprite_2d.position.y = -18.0
		animated_sprite_2d.play("sred")
		$Node2D.position.y = -30.0
		change_state(states.ATTACKING)
func walk():
	animated_sprite_2d.play("walk")
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		change_state(states.IDLE)
	elif Input.is_action_just_pressed("ui_accept"):
		change_state(states.JUMPING)
	elif Input.is_action_just_pressed("attack1"):
		animated_sprite_2d.play("punch")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("kick"):
		animated_sprite_2d.play("kick")
		change_state(states.ATTACKING)

func attack():
	pass
func died():
	pass
func jumping():
	pass
	


func _on_timer_timeout()-> void:
	if states.ATTACKING and animated_sprite_2d.animation =="blue":
		red.play()
		var bullet = bullet_path.instantiate()
		var ani = bullet.get_node("AnimationPlayer")
		var spr = bullet.get_node("Sprite2D")
		bullet.pos = $Node2D.global_position
		if animated_sprite_2d.flip_h == true:
			bullet.speed = -555
			spr.flip_h = true
			ani.play_backwards("bullet")
		else:
			ani.play("bullet")
			bullet.speed = 555
		get_parent().add_child(bullet)
	


func _on_timer_2_timeout()-> void:
	if states.ATTACKING and animated_sprite_2d.animation == "red":
		red.play()
		var bullet = bullet_path1.instantiate()
		var ani = bullet.get_node("AnimationPlayer")
		var spr = bullet.get_node("Sprite2D")
		bullet.pos = $Node2D.global_position
		if animated_sprite_2d.flip_h == true:
			bullet.speed = -555
			spr.flip_h = true
			ani.play_backwards("bullet")
		else:
			ani.play("bullet")
			bullet.speed = 555
		get_parent().add_child(bullet)
	
	
		
func _hit():
	var direc = global_position.x - enemy.global_position.x
	health -= 10 
	print(health) 
	if health <= 0:
		change_state(states.DIED)
		animated_sprite_2d.play("dead")
		dead.start()
		Engine.time_scale = 0.5
		velocity.x = direc * 20
		timer.stop()
		timer2.stop()
	else:
		change_state(states.DIED)
		animated_sprite_2d.play("hit")
		velocity.x = direc * 20
		timer.stop()
		timer2.stop()
func m_hit():
	health -= 5
	if health <= 60:
		animated_sprite_2d.play("damaged")
		change_state(states.DIED)

func slice():
	health -= 15
	if health <= 0:
		change_state(states.DIED)
		$sukuna_laugh.play()
		label.visible = true
		animated_sprite_2d.position.y = 13.0
		animated_sprite_2d.scale.x = 1
		animated_sprite_2d.scale.y = 1.1
		animated_sprite_2d.play("slice")
		velocity.x = 0
		enemy.hedied()
func restorehealth():
	health += 30
func _on_animated_sprite_2d_animation_finished() -> void:
	if not animated_sprite_2d.animation == "sred" and not animated_sprite_2d.animation == "slice" and not animated_sprite_2d.animation == "dead" and not animated_sprite_2d.animation == "punch" or animated_sprite_2d.animation == "jump":
		change_state(states.IDLE)
	var over = hitbox.get_overlapping_bodies()
	if animated_sprite_2d.animation == "punch":
		animated_sprite_2d.play("kick")
	if animated_sprite_2d.animation == "dead":
		label.visible = true
	if animated_sprite_2d.animation == "red":
		red_starting.stop()
	if animated_sprite_2d.animation == "kick" or animated_sprite_2d.animation == "punch":
		for area in over:
			if area.is_in_group("hit"):
				$"punch sound".play()
				enemy.damage_received()
	if animated_sprite_2d.animation == "sred":
		red.play()
		animation_player.play("ro")
		$ured.visible = true
		sred_timer.start()
				
func _on_dead_timeout() -> void:
	label.visible = false
	Engine.time_scale = 1
	get_tree().reload_current_scene()


func _on_sred_timer_timeout() -> void:
	red.play()
	animation_player.play("ured move")
	$ured.visible = false
	var bullet = bullet_path1.instantiate()
	var ani = bullet.get_node("AnimationPlayer")
	bullet.pos = $Node2D.global_position
	bullet.speed = 0
	bullet.velocity.y = -555
	ani.play("bullet")
	get_parent().add_child(bullet)
	$Node2D.position.y = -7.0
	change_state(states.IDLE)
	animated_sprite_2d.position.y = 0.0


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("RESET")
