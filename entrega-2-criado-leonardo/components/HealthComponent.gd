extends Node
class_name HealthComponent

## Componente reutilizable para manejar la salud de entidades
## Aplica el patrón de composición para separar responsabilidades

# Señales para comunicación
signal health_changed(current_health: int, max_health: int)
signal died
signal damage_taken(damage: int)

@export var max_health: int = 3

var current_health: int

func _ready() -> void:
	current_health = max_health

func take_damage(damage: int) -> void:
	"""Aplica daño a la entidad"""
	if current_health <= 0:
		return  # Ya está muerto
	
	current_health = max(0, current_health - damage)
	damage_taken.emit(damage)
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	"""Cura a la entidad"""
	if current_health <= 0:
		return  # No puede curarse si está muerto
	
	current_health = min(max_health, current_health + amount)
	health_changed.emit(current_health, max_health)

func is_alive() -> bool:
	"""Retorna si la entidad está viva"""
	return current_health > 0

func get_health_percentage() -> float:
	"""Retorna el porcentaje de salud (0.0 a 1.0)"""
	if max_health <= 0:
		return 0.0
	return float(current_health) / float(max_health)

func set_max_health(new_max: int) -> void:
	"""Establece nueva salud máxima y ajusta la actual proporcionalmente"""
	if new_max <= 0:
		return
	
	var percentage = get_health_percentage()
	max_health = new_max
	current_health = int(percentage * max_health)
	health_changed.emit(current_health, max_health)
