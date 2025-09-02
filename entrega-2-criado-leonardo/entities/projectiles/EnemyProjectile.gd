extends Projectile
class_name EnemyProjectile

## Proyectil específico de las torres enemigas
## Hereda de Projectile y añade comportamientos específicos para enemigos

signal hit(damage)

func _ready() -> void:
	# Llamar al _ready() de la clase padre
	super._ready()
	
	# Configuraciones específicas del proyectil enemigo
	damage = 1
	speed = 300.0
	lifetime = 4.0

func set_speed(new_speed: float) -> void:
	"""Establece una nueva velocidad para el proyectil"""
	speed = new_speed

func _on_body_entered(body: Node) -> void:
	"""Maneja las colisiones específicas del proyectil enemigo.
	Busca hacia arriba en la jerarquía para encontrar un nodo en el grupo 'player' y aplica daño.
	"""
	print("[EnemyProjectile] _on_body_entered called with: ", body.name, " type:", body.get_class())
	var target: Node = body
	# Subir por la cadena de padres para localizar un nodo en el grupo 'player'
	while target and not target.is_in_group("player"):
		target = target.get_parent()

	if target and target.is_in_group("player"):
		print("[EnemyProjectile] Found player target: ", target.name)
		# Emitir señal para notificar que se golpeó al jugador
		emit_signal("hit", damage)
		_destroy_projectile()
		return

	# Si no es player, comprobar si colisiona con environment
	var env_check: Node = body
	while env_check:
		if env_check.is_in_group("environment"):
			_destroy_projectile()
			return
		env_check = env_check.get_parent()
