extends RigidBody2D
class_name Projectile

## Clase base para todos los proyectiles
## Maneja la velocidad, dirección y destrucción automática

# Señales para comunicación
signal projectile_destroyed
signal target_hit(target: Node, damage: int)

@export var speed: float = 300.0
@export var damage: int = 1
@export var lifetime: float = 5.0

var direction: Vector2 = Vector2.RIGHT

func _ready() -> void:
	# Configurar timer para destruir el proyectil después del tiempo de vida
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_destroy_projectile)
	add_child(timer)
	timer.start()

func set_direction(new_direction: Vector2) -> void:
	"""Establece la dirección del proyectil"""
	direction = new_direction.normalized()
	rotation = direction.angle()
	# Aplicar la velocidad en la dirección correcta
	linear_velocity = direction * speed

func _destroy_projectile() -> void:
	"""Destruye el proyectil"""
	projectile_destroyed.emit()
	queue_free()

func _on_body_entered(_body: Node) -> void:
	"""Maneja las colisiones del proyectil"""
	# Implementar en las clases hijas según sea necesario
	pass
