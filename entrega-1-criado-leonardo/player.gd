extends Area2D

@export var speed = 400
var screen_size
var radius = 0.0

@export var rotation_speed = 10.0  # más alto = más rápido

func _ready():
	screen_size = get_viewport_rect().size
	var shape = $CollisionShape2D.shape
	if shape is CircleShape2D:
		radius = shape.radius + 18

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()

		# --- Rotación hacia dirección del movimiento (corrigiendo desfase de sprite) ---
		var target_angle = velocity.angle() + PI/2
		$AnimatedSprite2D.rotation = lerp_angle(
			$AnimatedSprite2D.rotation,
			target_angle,
			rotation_speed * delta
		)
	else:
		$AnimatedSprite2D.stop()

	# Movimiento
	position += velocity * delta

	# Ajustar con el radio de colisión
	position.x = clamp(position.x, radius, screen_size.x - radius)
	position.y = clamp(position.y, radius, screen_size.y - radius)
