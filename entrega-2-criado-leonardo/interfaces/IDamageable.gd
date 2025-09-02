extends Node
class_name IDamageable

## Interfaz para entidades que pueden recibir daño
## Define el contrato que deben implementar todas las entidades dañables

# Esta es una "interfaz" en GDScript - una clase que define métodos virtuales
# que deben ser implementados por las clases hijas

func take_damage(_damage: int) -> void:
	"""Método virtual que debe ser implementado por las clases hijas"""
	assert(false, "take_damage debe ser implementado en la clase hija")

func is_alive() -> bool:
	"""Método virtual que debe ser implementado por las clases hijas"""
	assert(false, "is_alive debe ser implementado en la clase hija")
	return false

func get_health_percentage() -> float:
	"""Método virtual que debe ser implementado por las clases hijas"""
	assert(false, "get_health_percentage debe ser implementado en la clase hija")
	return 0.0
