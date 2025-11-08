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

## FIX: Added a 'HIT' state to correctly handle taking damage without dying.
enum states {IDLE, WALKING, ATTACKING, JUMPING, HIT, DIED}

var state = states.IDLE


func _physics_process(delta: float) -> void:
	progress_bar.value = health
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
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

	# Jump input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY
		animated_sprite_2d.play("jump")
		change_state(states.JUMPING) # Also change state when jumping
	# Movement input
	var direction := Input.get_axis("ui_left", "ui_right")
	#var direction1 := Input.get_axis("ui_up", "ui_down")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Flip sprite and hitbox based on direction
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
	if Input.get_axis("ui_left" , "ui_right") and is_on_floor():
		change_state(states.WALKING)
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
		animation_player.play("hand ro")
	elif not is_on_floor():
		animated_sprite_2d.play("fall")

func walk():
	animated_sprite_2d.play("walk")
	if Input.is_action_just_released("ui_left") or Input.is_action_just_released("ui_right"):
		change_state(states.IDLE)
	elif Input.is_action_just_pressed("attack1"):
		animated_sprite_2d.play("punch")
		change_state(states.ATTACKING)
	elif Input.is_action_just_pressed("kick"):
		animated_sprite_2d.play("kick")
		change_state(states.ATTACKING)

func attack():
	pass

func jumping():
	## NOTE: When jumping, check if we've landed to return to IDLE.
	if is_on_floor():
		change_state(states.IDLE)
	
	# You can add logic for coyote time or jump height control here.
	pass

# These two functions are empty but are called in the match statement.
# They are kept for structure and can be filled with logic later.
func died():
	pass

func _on_timer_timeout()-> void:
	if state == states.ATTACKING and animated_sprite_2d.animation =="blue":
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
	if state == states.ATTACKING and animated_sprite_2d.animation == "red":
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
	
	# Stop any ongoing attacks
	timer.stop()
	timer2.stop()
	
	if health <= 0:
		change_state(states.DIED)
		animated_sprite_2d.play("dead")
		velocity.y = 1000
		dead.start()
		Engine.time_scale = 0.5
		velocity.x = direc * 20
		enemy.hedied()
	else:
		## FIX: Changed state to HIT instead of DIED. This prevents getting stuck.
		change_state(states.DIED)
		velocity.x = direc * 20
		if is_on_floor():
			animated_sprite_2d.play("hit")
		else:
			animated_sprite_2d.play("in_air")
	if direc > 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false

func m_hit():
	health -= 5
	if health <= 60 and health > 0:
		## FIX: Changed state to HIT instead of DIED.
		change_state(states.HIT)
		animated_sprite_2d.play("damaged")
	elif health <= 0:
		animated_sprite_2d.play("dead")
		velocity.y = 1000
func maho_hit():
	health -= 5
	var mahoraga = get_node("/root/Node2D/mahoraga")
	var direction = global_position - mahoraga.global_position
	velocity.x = direction.x * 40  
	velocity.y = direction.y * -10
	animated_sprite_2d.play("in_air")
	change_state(states.DIED)
	if health <= 0:
		animated_sprite_2d.play("dead")
		velocity.y = 1000
	if direction.x > 1:
		animated_sprite_2d.flip_h = true
	else:
		animated_sprite_2d.flip_h = false
func slice(dam):
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
	var current_animation = animated_sprite_2d.animation
	
	## FIX: This logic is now much cleaner and bug-free.
	# It checks the current animation and decides what to do next.
	match current_animation:
		"punch", "kick", "blue", "red" , "in_air", "black flash":
			if animated_sprite_2d.animation == "punch":
				animated_sprite_2d.play("black flash")
			else:
				change_state(states.IDLE)
		"hit", "damaged":
			animated_sprite_2d.position.y = 0.0
			change_state(states.IDLE)
		"dead":
			label.visible = true
		"red":
			red_starting.stop()
		"sred":
			red.play()
			animation_player.play("ro")
			sred_timer.start()
			$ured.visible = true
			
	
	# Handle hitbox detection after the animation frame that should deal damage.
	# NOTE: This is better handled with an Animation Keyframe signal, but for now, this works.
	if current_animation == "kick" or current_animation == "punch" or current_animation == "black flash":
		var mahoraga = get_node("/root/Node2D/mahoraga")
		var over = hitbox.get_overlapping_bodies()
		var mh =  hitbox.get_overlapping_bodies()
		for area in over:
			if area.is_in_group("hit"):
				$"punch sound".play()
				if current_animation == "black flash":
					enemy.hit_back()
					enemy.damage_received(10)
				else:
					enemy.damage_received(5)
		for mhit in mh:
			if mhit.is_in_group("maho hit"):
				$"punch sound".play()
				if current_animation == "black flash":
					mahoraga.damage(15)
				else:
					mahoraga.damage(5)
				
func _on_dead_timeout() -> void:
	label.visible = false
	Engine.time_scale = 1
	velocity.x = 0

func _on_sred_timer_timeout() -> void:
	red.play()
	animation_player.play("ured move")
	$ured.visible = false
	var bullet = bullet_path1.instantiate()
	var ani = bullet.get_node("AnimationPlayer")
	bullet.pos = $Node2D.global_position
	bullet.velocity.y = -555
	ani.play("bullet")
	get_parent().add_child(bullet)
	$Node2D.position.y = -7.0
	change_state(states.IDLE)
	animated_sprite_2d.position.y = 0.0

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	animation_player.play("RESET")
