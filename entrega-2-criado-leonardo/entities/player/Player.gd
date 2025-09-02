extends RigidBody2D
class_name Player

## Jugador principal del juego
## Maneja movimiento, vida y disparo a través del cañón

# Configuración de movimiento con física
@export var max_speed: float = 300.0  # Velocidad máxima
@export var acceleration: float = 800.0  # Aceleración cuando se presiona una tecla
@export var friction: float = 600.0  # Fricción cuando no se presiona nada

@onready var cannon = $Cañon
@onready var sprite = $Sprite2D

# Límites de la pantalla
var screen_width: float
var sprite_half_width: float

# Sistema de vida
@export var max_health: int = 3
var current_health: int

# Variables de física para movimiento suave
var velocity: float = 0.0  # Velocidad actual horizontal

func _ready() -> void:
	# Añadir al grupo para identificación por otros sistemas
	add_to_group("player")
	
	# Obtener el ancho de la pantalla
	screen_width = get_viewport().get_visible_rect().size.x
	
	# Calcular la mitad del ancho del sprite para los límites
	if sprite and sprite.texture:
		sprite_half_width = sprite.texture.get_width() / 2.0
	else:
		sprite_half_width = 0.0
	
	# Inicializar vida
	current_health = max_health
	
	# Configurar RigidBody2D
	gravity_scale = 0.0  # Sin gravedad para juego 2D tipo nave
	lock_rotation = true  # Evitar rotación del cuerpo

func _physics_process(delta):
	# Rotación del cañón hacia el mouse
	var mouse_position = get_viewport().get_mouse_position()
	var angle = (mouse_position - cannon.global_position).angle()
	cannon.rotation = angle
	
	# Sistema de movimiento con aceleración y fricción
	var input_direction: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	# Aplicar aceleración o fricción según el input
	if input_direction != 0:
		# Hay input: acelerar en la dirección deseada
		velocity += input_direction * acceleration * delta
		# Limitar a la velocidad máxima
		velocity = clamp(velocity, -max_speed, max_speed)
	else:
		# No hay input: aplicar fricción
		if abs(velocity) > friction * delta:
			# Reducir velocidad gradualmente
			velocity -= sign(velocity) * friction * delta
		else:
			# Detener completamente si la velocidad es muy baja
			velocity = 0.0
	
	# Calcular nueva posición usando RigidBody2D
	var new_velocity = Vector2(velocity, 0)
	
	# Aplicar límites considerando el borde del sprite
	var left_limit = sprite_half_width
	var right_limit = screen_width - sprite_half_width
	
	# Verificar colisión con límites y ajustar velocidad
	if global_position.x + new_velocity.x * delta <= left_limit:
		new_velocity.x = 0
		global_position.x = left_limit
	elif global_position.x + new_velocity.x * delta >= right_limit:
		new_velocity.x = 0
		global_position.x = right_limit
	
	# Aplicar la velocidad al RigidBody2D
	linear_velocity = new_velocity

	# Permitir que el cañón intente disparar (esto asegura que el jugador pueda disparar mientras se mueve)
	# Centralizar input en Player: calcular intención de disparo y pasarla al cañón
	# Detectar intención de disparo exclusivamente a través de la acción "fire"
	var should_fire: bool = Input.is_action_pressed("fire") or Input.is_action_just_pressed("fire")
	if cannon and cannon.has_method("try_fire"):
		cannon.try_fire(should_fire)

func take_damage(damage_amount: int) -> void:
	"""Recibe daño y maneja la muerte del jugador"""
	current_health -= damage_amount
	print("[Player] take_damage called, damage=", damage_amount, " new_health=", current_health)
	
	if current_health <= 0:
		die()

func die() -> void:
	"""Maneja la muerte del jugador"""
	# Aquí puedes añadir efectos, reiniciar nivel, etc.
	queue_free()
