extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window.

@export var max_health = 100
var current_health = max_health
@onready var health_fill = $HealthBarBackground/HealthBarFill
@onready var health_background = $HealthBarBackground

func _ready():
	screen_size = get_viewport_rect().size
	hide()


func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed(&"move_right"):
		velocity.x += 1
	if Input.is_action_pressed(&"move_left"):
		velocity.x -= 1
	if Input.is_action_pressed(&"move_down"):
		velocity.y += 1
	if Input.is_action_pressed(&"move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()

	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = &"walk"
		$AnimatedSprite2D.flip_v = false
		# $Trail.rotation = 0
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = &"up"
		rotation = PI if velocity.y > 0 else 0


func start(pos):
	position = pos
	rotation = 0
	current_health = max_health
	update_health_bar()
	show()
	$CollisionShape2D.disabled = false


func _on_body_entered(_body):
	current_health -= 25
	update_health_bar()
	if current_health <= 0:
		hide()
		hit.emit()
		$CollisionShape2D.set_deferred(&"disabled", true)
	
func update_health_bar():
	var percent = float(current_health) / max_health
	health_fill.size.x = health_background.size.x * percent
