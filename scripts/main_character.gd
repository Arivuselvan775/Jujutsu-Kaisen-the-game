extends CharacterBody2D

# These run only when the node is ready in the scene tree
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var timer2: Timer = $Timer2
@onready var enemy = get_node("/root/Node2D/enemy")
@onready var dead: Timer = $dead
@onready var label: Label = $Label
@onready var red_starting: AudioStreamPlayer2D = $"red starting"
@onready var collision_shape_2d: CollisionShape2D = $AnimatedSprite2D/hitbox/CollisionShape2D
@onready var timer_3: Timer = $Timer3
@onready var hitbox: Area2D = $AnimatedSprite2D/hitbox
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sred_timer: Timer = $"sred timer"
@onready var animated_sprite_2: AnimatedSprite2D = $AnimatedSprite2D2
#@onready var animated_sprite_2: AnimatedSprite2D = $CanvasLayer/AnimatedSprite2D2
@onready var black: AnimatedSprite2D = $black
@onready var wall_slam: AnimatedSprite2D = $"wall slam"
@onready var camera_2d: Camera2D = $Camera2D
@onready var final_execution: Label = $"final execution"
@onready var mobile_control: CanvasLayer = $"mobile control"
@onready var healthbar: ProgressBar = $Healthbar



# Constants (unchangeable values)
var SPEED = 300.0
const JUMP_VELOCITY = -400.0
#health 
var health = 100

var pur = false
var can_red = false
var can_purple = false
var can_damaged = true
var move = false
var blue_ammo = 5
var red_ammo = 5
var first_blue = true
var final = false

# Preload bullet scene (so it’s ready in memory)
var bullet_path = preload("res://scenes/blue.tscn")
var bullet_path1 = preload("res://scenes/red.tscn")
var hallow = preload("res://scenes/hallow_purple.tscn")
var upblue = preload("res://scenes/up blue.tscn")
var upred = preload("res://scenes/up_red.tscn")
## FIX: Added a 'HIT' state to correctly handle taking damage without dying.
enum states {IDLE, WALKING, ATTACKING, JUMPING, HIT, DIED, PURPLE, PURPLE0, EXECUTION, GRAB}

var state = states.IDLE

func _physics_process(delta: float) -> void:
	#print(can_damaged)
	var wall = hitbox.get_overlapping_bodies()
	if move == true:
		var direction1 = global_position.direction_to(enemy.global_position)
		velocity.x = direction1.x * 1500
		camera_2d.shake(0.3)
		for area in wall:
			if area.is_in_group("building"):
				wall_slam.visible = true
				wall_slam.play("slam")
				enemy.animated_sprite.play("hit_back 2")
				animated_sprite_2d.position.x = 0
				animated_sprite_2d.position.y = 0
				SPEED = 300.0
				enemy.change_state(3)
				enemy.collision_shape_2d.disabled = false
				can_damaged = true
				enemy.animated_sprite_2d_2.visible = false
				move = false
				camera_2d.shake(4.0)
	healthbar.value = health
	# Match the current state to run its specific logic
	match state:
		states.IDLE:
			idle()
		states.WALKING:
			walk()
		states.ATTACKING:
			attack()
		states.JUMPING:
			jumping()
		states.PURPLE:
			purple1()
		states.PURPLE0:
			purple0()
		states.EXECUTION:
			execution()
		states.HIT:
			# In the HIT state, we mostly just wait for the animation to finish.
			# Gravity and movement can still apply for knockback.
			pass 
		states.DIED:
			# The died() function is empty, so we can put logic here or there.
			# For now, we just let gravity affect the body.
			pass

	## NOTE: This logic runs for most states, but we block it for specific ones.
	if state == states.DIED:
		# Stop player input and gravity logic during these states
		move_and_slide()
		return

	# Gravity
	if not is_on_floor() and pur == false:
		velocity.y += get_gravity().y * delta
	# Jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not state == states.EXECUTION and move == false: 
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("jump")
		change_state(states.JUMPING) # Also change state when jumping
	# Movement input
	var direction := Input.get_axis("ui_left", "ui_right")
	#var direction1 := Input.get_axis("ui_up", "ui_down")
	if direction and move == false:
		velocity.x = direction * SPEED
	elif not animated_sprite_2d.animation == "finish1" and move == false:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Flip sprite and hitbox based on direction
	if velocity.x < 0 and not animated_sprite_2d.animation == "finish1":
		animated_sprite_2d.flip_h = true
	elif velocity.x > 0 and not animated_sprite_2d.animation == "finish1":
		animated_sprite_2d.flip_h = false
		
	if animated_sprite_2d.flip_h == true:
		collision_shape_2d.position.x = -15.5
	else:
		collision_shape_2d.position.x = 15.5

		
func change_state(new_state):
	state = new_state

func idle():
	if state == states.EXECUTION:
		return
	animated_sprite_2d.play("default")
	if Input.get_axis("ui_left" , "ui_right") and is_on_floor():
		change_state(states.WALKING)
	elif Input.is_action_just_pressed("blue") and enemy.execution == false:
		if blue_ammo > 0:
			animated_sprite_2d.play("blue")
			timer.start()
			change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("blue") and enemy.label.text == "A" and hitbox.overlaps_body(enemy):
		$"exe timer".start()
		Engine.time_scale = 0.7
		animated_sprite_2d.play("black flash")
		#animation_player.play("black_flash")
		change_state(states.ATTACKING)
		can_damaged = false
	elif Input.is_action_just_pressed("red") and enemy.execution1 == false:
		if red_ammo > 0:
			animated_sprite_2d.play("red")
			timer2.start()
			red_starting.play()
			change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("red") and enemy.label.text == "S" and hitbox.overlaps_body(enemy):
		animated_sprite_2d.play("finish1")
		timer2.wait_time = 1.2
		timer2.start()
		change_state(states.ATTACKING)
		can_damaged = false
	elif Input.is_action_just_pressed("attack1") and enemy.label.text == "W" and hitbox.overlaps_body(enemy):
		animated_sprite_2d.play("punch1")
		change_state(states.EXECUTION)
		can_damaged = false
	elif Input.is_action_pressed("attack1") and enemy.execution3 == false:
		animated_sprite_2d.play("punch1")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("kick") and enemy.execution3 == false and enemy.execution4 == false:
		#can_damaged = false
		animated_sprite_2d.play("kick")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("kick") and enemy.execution4 and hitbox.overlaps_body(enemy):
		animated_sprite_2d.play("final flash")
		can_damaged = false
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("sred") and can_red:
		can_damaged = false
		animated_sprite_2d.position.y = -18.0
		animated_sprite_2d.play("sred")
		$Node2D.position.y = -30.0
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("begin") and can_red and can_purple and final:
		animated_sprite_2d.play("purple begin")
		enemy.execution7 += 1
		animation_player.play("ured move")
		enemy.execution5 = false
		$hallow_final.play()
		change_state(states.PURPLE0)
		can_damaged = false
	elif Input.is_action_just_pressed("domain") and enemy.execution2 == true and hitbox.overlaps_body(enemy):
		Engine.time_scale = 0.9
		animated_sprite_2d.play("black_flash1")
		animation_player.play("black_flash")
		can_damaged = false
		change_state(states.EXECUTION)
	elif not is_on_floor():
		pur = false
		animated_sprite_2d.play("fall")

func walk():
	if state == states.EXECUTION:
		return
	animated_sprite_2d.play("walk")
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		change_state(states.IDLE)
	elif Input.is_action_pressed("attack1") and enemy.execution3 == false:
		animated_sprite_2d.play("punch1")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("kick") and enemy.execution3 == false and enemy.execution4 == false:
		animated_sprite_2d.play("kick")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("blue") and enemy.execution == false:
		if blue_ammo > 0:
			animated_sprite_2d.play("blue")
			timer.start()
			change_state(states.ATTACKING)
func attack():
	pass

func jumping():
	## NOTE: When jumping, check if we've landed to return to IDLE.
	if is_on_floor() and not state == states.EXECUTION:
		change_state(states.IDLE)
	
	# You can add logic for coyote time or jump height control here.
	pass
func purple1():
	if global_position.y <= 250:
		velocity.y = 0.0
func purple0():
	pur = true
	if is_on_floor():
		velocity.y += -20
	elif global_position.y <= 250:
		final_execution.text = "Q"
		animation_player.play("final execution")
		mobile_control.exe_5.visible = true
		velocity.y = 0.0
	if Input.is_action_just_pressed("hallow purple") and final_execution.text == "Q" and velocity.y == 0.0:
		mobile_control.exe_5.visible = true
		final_execution.visible = false 
		animation_player.play("RESET")
		change_state(states.PURPLE)
func execution():
	pass
func died():
	pass

func _on_timer_timeout()-> void:
	if animated_sprite_2d.animation == "blue":
		blue_ammo -= 1
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
	if state == states.ATTACKING and animated_sprite_2d.animation == "red" or animated_sprite_2d.animation == "finish1":
		if not animated_sprite_2d.animation == "finish1":
			red_ammo -= 1
		if animated_sprite_2d.animation == "finish1":
			if animated_sprite_2d.flip_h == false:
				velocity.x = -700
			elif animated_sprite_2d.flip_h == true:
				velocity.x = 700
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
	if can_damaged == true:
		health -= 10 
		# Stop any ongoing attacks
		timer.stop()
		timer2.stop()
	
	if health <= 0:
		change_state(states.DIED)
		animated_sprite_2d.play("dead")
		velocity.y = 1000
		dead.start()
		Engine.time_scale = 0.5
		velocity.x = direc * 40
		enemy.hedied()
	elif can_damaged == true:
		camera_2d.shake(0.7)
		## FIX: Changed state to HIT instead of DIED. This prevents getting stuck.
		change_state(states.DIED)
		velocity.x = direc * 40
		if is_on_floor():
			animated_sprite_2d.play("hit")
		else:
			animated_sprite_2d.play("in_air")
	if direc > 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false

func m_hit():
	if can_damaged == true:
		camera_2d.shake(0.1)
		health -= 5
	if health <= 30 and health > 0 and can_damaged == true:
		## FIX: Changed state to HIT instead of DIED.
		change_state(states.HIT)
		animated_sprite_2d.play("damaged")
		camera_2d.shake(0.1)
	elif health <= 0:
		change_state(states.DIED)
		animated_sprite_2d.play("dead")
		velocity.y = 1000
		enemy.hedied()
func maho_hit():
	if can_damaged == false:
		return
	else:
		health -= 5
		var mahoraga = get_node("/root/Node2D/mahoraga")
		var direction = global_position - mahoraga.global_position
		velocity.x = direction.x * 40  
		velocity.y = direction.y * -10
		animated_sprite_2d.play("in_air")
		change_state(states.DIED)
		if health <= 0:
			change_state(states.DIED)
			animated_sprite_2d.play("dead")
			velocity.y = 1000
			enemy.hedied()
		if direction.x > 1:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
func slice(dam):
	if can_damaged == false:
		return
	health -= dam
	if health <= 0:
		change_state(states.DIED)
		$sukuna_laugh.play()
		label.visible = true
		animated_sprite_2d.position.y = 13.0
		animated_sprite_2d.scale.x = 1
		animated_sprite_2d.scale.y = 1.1
		animated_sprite_2d.play("slice")
		velocity.x = 0
		velocity.y = 1000 
		enemy.hedied()

func restorehealth():
	health += 30

func _on_animated_sprite_2d_animation_finished() -> void:
	timer2.wait_time = 1.0
	var current_animation = animated_sprite_2d.animation
	
	## FIX: This logic is now much cleaner and bug-free.
	# It checks the current animation and decides what to do next.
	match current_animation:
		"punch1","punch", "blue", "red" , "in_air", "hallow":
			if animated_sprite_2d.animation == "punch1" and enemy.execution3 == false:
				animated_sprite_2d.play("punch")
			elif animated_sprite_2d.animation == "punch1" and enemy.execution3 == true:
				can_damaged = false
				animated_sprite_2d.play("kick")
			else:
				rotation_degrees = 0.0
				Engine.time_scale = 1.0
				change_state(states.IDLE)
		"domain_expansion":
			animated_sprite_2.play("infinite_void_start")
			animated_sprite_2.visible = true
		"finish1":
			enemy.can_execution(1)
			change_state(states.IDLE)
			can_damaged = true
			enemy.execution1 = false
			enemy.animation_player.play("RESET")
			Engine.time_scale = 1.0
		"punch3":
			animated_sprite_2d.play("kick")
		"kick":
			if enemy.execution3:
				animated_sprite_2d.play("black flash")
				health += 50
			else:
				animated_sprite_2d.play("black_flash2")
		"black flash":
			change_state(states.IDLE)
		"black_flash2":
			change_state(states.IDLE)
			can_damaged = true
			enemy.change_state(1)
		"hit", "damaged":
			animated_sprite_2d.position.y = 0.0
			change_state(states.IDLE)
		"black_flash1":
			Engine.time_scale = 1.0
			black.visible = true
			black.play("black flash effect")
			enemy.can_execution(2)
			#change_state(states.IDLE)
			enemy.animation_player.play("RESET")
			enemy.execution2 = false
			animation_player.play("RESET")
			camera_2d.shake(1.0)
		"hallow":
			animation_player.play("RESET")
		"dash_1":
			animated_sprite_2d.position.x = 0
			animated_sprite_2d.position.y = 0
			SPEED = 300.0
			enemy.change_state(1)
			enemy.collision_shape_2d.disabled = false
			move = false
			can_damaged = true
			change_state(states.IDLE)
		"dead":
			change_state(states.DIED)
			label.visible = true
		"red":
			red_starting.stop()
		"sred":
			animation_player.play("ro")
			sred_timer.start()
			$ured.visible = true
			
	
	# Handle hitbox detection after the animation frame that should deal damage.
	# NOTE: This is better handled with an Animation Keyframe signal, but for now, this works.
	if current_animation == "kick" or current_animation == "punch" or current_animation == "black flash"or current_animation == "punch1" or current_animation == "punch2" or current_animation == "finish1" or current_animation == "black_flash2" or current_animation == "final flash":
		var over = hitbox.get_overlapping_bodies()
		var mh =  hitbox.get_overlapping_bodies()
		for area in over:
			if area.is_in_group("hit"):
				$"punch sound".play()
				if current_animation == "black flash":
					black.visible = true
					black.play("black flash effect")
					Engine.time_scale = 1.0
					enemy.can_execution(1)
					can_damaged = true
					enemy.execution = false
					enemy.animation_player.play("RESET")
					change_state(states.IDLE)
					camera_2d.shake(1.0)
					enemy.execution3 = false
				elif current_animation == "black_flash2":
					camera_2d.shake(0.4)
					black.play("black flash effect")
					black.visible = true
					enemy.damage_received(5)
					enemy.can_execution(3)
				elif current_animation == "final flash":
					$sblue.start()
					camera_2d.shake(0.8)
					black.play("black flash effect")
					enemy.animation_player.play("RESET")
					black.visible = true
					enemy.damage_received(10)
					enemy.can_execution(4)
					change_state(states.IDLE)
					enemy.execution7 += 1
				else:
					camera_2d.shake(0.2)
					enemy.damage_received(1)
		for mhit in mh:
			if mhit.is_in_group("maho hit"):
				var mahoraga = get_node("/root/Node2D/mahoraga")
				$"punch sound".play()
				if current_animation == "black_flash2":
					mahoraga.damage(15)
				else:
					mahoraga.damage(5)
				
func _on_dead_timeout() -> void:
	label.visible = false
	Engine.time_scale = 1
	velocity.x = 0

func _on_sred_timer_timeout() -> void:
	enemy.animation_player.play("RESET")
	animation_player.play("ured move")
	$ured.visible = false
	var bullet = upred.instantiate()
	var ani = bullet.get_node("AnimationPlayer")
	bullet.pos = $Node2D.global_position
	bullet.velocity.y = -555
	ani.play("bullet")
	get_parent().add_child(bullet)
	$Node2D.position.y = -7.0
	animated_sprite_2d.position.y = 0.0
	can_damaged = true
	if not state == states.DIED:
		change_state(states.IDLE)

func _on_sblue_timeout() -> void:
	#enemy.animation_player.play("RESET")
	$ured.visible = false
	var bullet = upblue.instantiate()
	var ani = bullet.get_node("AnimationPlayer")
	bullet.pos = $Node2D.global_position
	bullet.velocity.y = -555
	ani.play("bullet")
	get_parent().add_child(bullet)
	$Node2D.position.y = -7.0
	animated_sprite_2d.position.y = 0.0
	can_damaged = true
	if not state == states.DIED:
		change_state(states.IDLE)
		
func fin():
	animated_sprite_2d.play("hallow")
	var posi = get_node("/root/Node2D/up red")
	var purple = hallow.instantiate()
	purple.pos = posi.global_position
	get_parent().add_child(purple)

func _on_animated_sprite_2d_2_animation_finished() -> void:
	if animated_sprite_2.animation == "infinite_void_start":
		animated_sprite_2.play("infinite_void_mid")
	elif animated_sprite_2.animation == "infinite_void_mid":
		enemy.change_state(7)
		animated_sprite_2.play("infinite_void_end")
		change_state(states.IDLE)
	elif animated_sprite_2.animation == "infinite_void_end":
		animated_sprite_2.visible = false
		enemy.change_state(1)

func _on_exe_timer_timeout() -> void:
	change_state(states.IDLE)
	Engine.time_scale = 1.0


func _on_wall_slam_animation_finished() -> void:
	wall_slam.visible = false
	change_state(states.IDLE)
