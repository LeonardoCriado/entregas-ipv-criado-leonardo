extends Sprite2D
class_name Cannon

## Clase que maneja el cañón del jugador
## Responsable de disparar proyectiles y manejar la cadencia de disparo

# Señales para comunicación con otros sistemas
signal projectile_fired(projectile: Node)

@export var projectile_scene: PackedScene = preload("res://entities/projectiles/PlayerProjectile.tscn")
@export var fire_rate: float = 0.3  # Tiempo entre disparos en segundos
@export var projectile_speed: float = 400.0

@onready var fire_point: Marker2D = get_node_or_null("FirePoint") as Marker2D
var can_fire: bool = true
var fire_timer: Timer

func _ready() -> void:
	# Crear el timer para controlar la cadencia de disparo
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)
	
	# Crear el punto de disparo si no existe
	if not fire_point:
		fire_point = Marker2D.new()
		fire_point.name = "FirePoint"
		add_child(fire_point)
		# Posicionar el punto de disparo en la punta del cañón
		if texture:
			fire_point.position.x = float(texture.get_width()) / 2.0
		else:
			fire_point.position.x = 0

func _physics_process(_delta: float) -> void:
	# Lógica de cañón que no maneja input directamente
	# (El Player llama a try_fire para permitir disparar mientras se mueve)
	pass

func try_fire(should_fire: bool = false) -> void:
		"""Intento público de disparo que el controlador (Player) puede llamar.
		Parámetros:
			should_fire - si true, el cañón intentará disparar. Si false, el cañón consulta el input (compatibilidad).
		Retorna inmediatamente si el cañón está en cooldown.
		"""
		var fire_intent: bool = should_fire
		# Compatibilidad: si no se pasa el flag, consultamos únicamente la acción "fire"
		if not fire_intent:
			fire_intent = (Input.is_action_pressed("fire") or Input.is_action_just_pressed("fire"))

		if fire_intent and can_fire:
			fire_projectile()

func fire_projectile() -> void:
	"""Dispara un proyectil desde el cañón hacia la posición del mouse"""
	if not can_fire or not projectile_scene:
		return
	
	# Instanciar el proyectil
	var projectile = projectile_scene.instantiate() as PlayerProjectile
	if not projectile:
		return
	
	# Obtener la escena principal para añadir el proyectil
	var main_scene = get_tree().current_scene
	main_scene.add_child(projectile)
	
	# Configurar posición del proyectil
	projectile.global_position = fire_point.global_position
	
	# Calcular dirección hacia la posición del mouse (sin Camera2D)
	var mouse_position = get_viewport().get_mouse_position()
	var fire_direction = (mouse_position - fire_point.global_position).normalized()
	
	# Establecer la velocidad del proyectil si es diferente
	if projectile_speed != projectile.speed:
		projectile.speed = projectile_speed
	
	# Configurar dirección (esto también aplicará la velocidad)
	projectile.set_direction(fire_direction)
	
	# Emitir señal para notificar que se disparó un proyectil
	projectile_fired.emit(projectile)
	
	# Activar el cooldown de disparo
	can_fire = false
	fire_timer.start()

func _on_fire_timer_timeout() -> void:
	"""Permite disparar nuevamente cuando termina el cooldown"""
	can_fire = true

func set_fire_rate(new_fire_rate: float) -> void:
	"""Cambia la cadencia de disparo"""
	fire_rate = new_fire_rate
	if fire_timer:
		fire_timer.wait_time = fire_rate
