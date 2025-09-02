extends Projectile
class_name PlayerProjectile

## Proyectil específico del jugador
## Hereda de Projectile y añade comportamientos específicos

func _ready() -> void:
	# Llamar al _ready() de la clase padre
	super._ready()
	
	# Configuraciones específicas del proyectil del jugador
	damage = 1
	speed = 400.0
	lifetime = 3.0

func _on_area_entered(area: Area2D) -> void:
	"""Maneja colisiones con Area2D (por ejemplo la Area2D hija de una torre)."""
	# Intentar obtener el nodo padre que represente al enemigo
	var owner_node := area.get_parent()
	if owner_node and owner_node.is_in_group("enemies") and owner_node.has_method("take_damage"):
		owner_node.take_damage(damage)
		_destroy_projectile()
	# Si el area pertenece al ambiente, destruir
	elif owner_node and owner_node.is_in_group("environment"):
		_destroy_projectile()

func _on_body_entered(body: Node) -> void:
	"""Maneja las colisiones específicas del proyectil del jugador"""
	# Colisionar con enemigos (torres)
	if body.is_in_group("enemies") and body.has_method("take_damage"):
		body.take_damage(damage)
		_destroy_projectile()
	elif body.is_in_group("environment"):
		_destroy_projectile()
