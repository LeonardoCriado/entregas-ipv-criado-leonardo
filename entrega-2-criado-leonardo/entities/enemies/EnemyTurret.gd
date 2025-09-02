extends Sprite2D
class_name EnemyTurret

## Torre enemiga que dispara al jugador
## Maneja la detección del jugador y el disparo automático

@export var projectile_scene: PackedScene = preload("res://entities/projectiles/EnemyProjectile.tscn")
@export var fire_rate: float = 1.0  # Dispara cada segundo
@export var detection_range: float = 600.0
@export var projectile_speed: float = 300.0
@export var initial_fire_delay: float = 2.0 # Segundos antes de que la torre comience a disparar
@export var randomize_initial_delay: bool = false
@export var initial_delay_variation: float = 1.0
@export var max_health: int = 3

@onready var fire_point: Marker2D = $FirePoint
var player: Node2D = null
var can_fire: bool = true
var fire_timer: Timer
var initial_timer: Timer
var current_health: int

func _ready() -> void:
	# Crear el timer para controlar la cadencia de disparo
	fire_timer = Timer.new()
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_timer_timeout)
	add_child(fire_timer)

	# Crear timer inicial para retrasar el primer disparo
	initial_timer = Timer.new()
	initial_timer.one_shot = true
	initial_timer.timeout.connect(_on_initial_timer_timeout)
	add_child(initial_timer)

	# Desactivar disparo inmediato hasta que pase el delay inicial
	can_fire = false
	var delay = initial_fire_delay
	if randomize_initial_delay:
		# variación alrededor del valor base
		var min_d = max(0.0, initial_fire_delay - initial_delay_variation)
		var max_d = initial_fire_delay + initial_delay_variation
		delay = randf_range(min_d, max_d)
	initial_timer.wait_time = delay
	initial_timer.start()
	
	# Inicializar salud
	current_health = max_health
	
	# Añadir al grupo de enemigos
	add_to_group("enemies")
	
	# Crear el punto de disparo si no existe
	if not fire_point:
		fire_point = Marker2D.new()
		fire_point.name = "FirePoint"
		add_child(fire_point)
		# Posicionar el punto de disparo en la punta frontal de la torre
		# El sprite apunta hacia arriba, por eso colocamos el punto en -half_height
		if texture:
			fire_point.position = Vector2(0, -texture.get_height() / 2)
		else:
			fire_point.position = Vector2.ZERO

	# Ajustar el CollisionShape2D (RectangleShape2D) para que encaje con la textura del sprite
	# Si el tscn contiene Area2D -> CollisionShape2D con RectangleShape2D, actualizar su tamaño
	var area_node := get_node_or_null("Area2D")
	if area_node:
		var col := area_node.get_node_or_null("CollisionShape2D")
		if col and col.shape and col.shape is RectangleShape2D:
			if texture:
				var tex_size = Vector2(texture.get_width(), texture.get_height())
				col.shape.size = tex_size
			else:
				col.shape.size = Vector2(32, 64)
	
	# Buscar al jugador en la escena
	_find_player()

func _find_player() -> void:
	"""Busca al jugador en la escena"""
	var main_scene = get_tree().current_scene
	player = main_scene.find_child("Player", true, false)

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		# Calcular distancia al jugador
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Si el jugador está en rango, apuntar y disparar
		if distance_to_player <= detection_range:
			_aim_at_player()
			
			if can_fire:
				fire_at_player()

func _aim_at_player() -> void:
	"""Apunta la torre hacia el jugador"""
	if player and is_instance_valid(player):
		var direction_to_player = (player.global_position - global_position).normalized()
		rotation = direction_to_player.angle() + PI/2  # +90 grados porque el sprite apunta hacia arriba

func fire_at_player() -> void:
	"""Dispara un proyectil hacia el jugador"""
	if not can_fire or not projectile_scene or not player or not is_instance_valid(player):
		return
	
	# Instanciar el proyectil
	var projectile = projectile_scene.instantiate()
	if not projectile:
		return
	
	# Obtener la escena principal para añadir el proyectil
	var main_scene = get_tree().current_scene
	main_scene.add_child(projectile)
	
	# Calcular la posición real de la punta frontal en coordenadas locales y transformarla a global
	var local_tip = Vector2.ZERO
	if texture:
		local_tip = Vector2(0, -texture.get_height() / 2)
	var world_tip = to_global(local_tip)
	projectile.global_position = world_tip

	# Calcular dirección hacia el jugador desde la punta
	var fire_direction = (player.global_position - projectile.global_position).normalized()
	
	# Establecer la velocidad del proyectil
	if projectile.has_method("set_speed"):
		projectile.set_speed(projectile_speed)
	
	# Configurar dirección
	if projectile.has_method("set_direction"):
		projectile.set_direction(fire_direction)

	# Conectar la señal de impacto al método take_damage del jugador (si existe)
	if player and is_instance_valid(player) and projectile.has_signal("hit") and player.has_method("take_damage"):
		projectile.connect("hit", Callable(player, "take_damage"))
	
	# Activar el cooldown de disparo
	can_fire = false
	fire_timer.start()

func _on_fire_timer_timeout() -> void:
	"""Permite disparar nuevamente cuando termina el cooldown"""
	can_fire = true

func _on_initial_timer_timeout() -> void:
	"""Habilita el disparo tras el delay inicial"""
	can_fire = true

func take_damage(damage_amount: int) -> void:
	"""Recibe daño del jugador"""
	current_health -= damage_amount
	if current_health <= 0:
		queue_free()
