extends Node
class_name ProjectileManager

## Manager singleton para centralizar la gestión de proyectiles
## Aplica el patrón Singleton para un punto central de control

signal projectile_spawned(projectile: Node)
signal projectile_destroyed(projectile: Node)

var active_projectiles: Array[Node] = []
var projectile_pool: Dictionary = {}

func spawn_projectile(scene: PackedScene, position: Vector2, direction: Vector2, speed: float = -1) -> Node:
	"""Crea un nuevo proyectil con los parámetros dados"""
	if not scene:
		push_error("ProjectileManager: scene is null")
		return null
	
	var projectile = scene.instantiate()
	if not projectile:
		push_error("ProjectileManager: Failed to instantiate projectile")
		return null
	
	# Añadir al árbol de la escena
	get_tree().current_scene.add_child(projectile)
	
	# Configurar posición
	projectile.global_position = position
	
	# Configurar velocidad si se especificó
	if speed > 0 and projectile.has_method("set") and "speed" in projectile:
		projectile.speed = speed
	
	# Configurar dirección
	if projectile.has_method("set_direction"):
		projectile.set_direction(direction)
	
	# Conectar señales si existen
	if projectile.has_signal("projectile_destroyed"):
		projectile.projectile_destroyed.connect(_on_projectile_destroyed.bind(projectile))
	
	# Registrar proyectil activo
	active_projectiles.append(projectile)
	projectile_spawned.emit(projectile)
	
	return projectile

func _on_projectile_destroyed(projectile: Node) -> void:
	"""Maneja la destrucción de un proyectil"""
	if projectile in active_projectiles:
		active_projectiles.erase(projectile)
	projectile_destroyed.emit(projectile)

func clear_all_projectiles() -> void:
	"""Elimina todos los proyectiles activos"""
	for projectile in active_projectiles:
		if is_instance_valid(projectile):
			projectile.queue_free()
	active_projectiles.clear()

func get_projectiles_by_group(group_name: String) -> Array[Node]:
	"""Retorna todos los proyectiles que pertenecen a un grupo específico"""
	var result: Array[Node] = []
	for projectile in active_projectiles:
		if is_instance_valid(projectile) and projectile.is_in_group(group_name):
			result.append(projectile)
	return result

func get_active_projectile_count() -> int:
	"""Retorna el número de proyectiles activos"""
	return active_projectiles.size()
