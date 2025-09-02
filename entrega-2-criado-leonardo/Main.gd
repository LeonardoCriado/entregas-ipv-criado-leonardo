extends Node

# Spawner para colocar N torres aleatorias por encima del jugador sin superposiciones
@export var turret_scene: PackedScene = preload("res://entities/enemies/EnemyTurret.tscn")
@export var turret_count: int = 3
@export var min_distance_between_turrets: float = 120.0
@export var min_height_above_player: float = 80.0
@export var max_height_above_player: float = 220.0
@export var max_attempts_per_turret: int = 30

func _ready() -> void:
	var main_scene = get_tree().current_scene
	var player = null
	if main_scene:
		player = main_scene.find_child("Player", true, false)
	if not player:
		return

	var viewport_rect = get_viewport().get_visible_rect()
	# Área horizontal completa del viewport
	var x_min = 0 + 50
	var x_max = viewport_rect.size.x - 50

	var placed_positions: Array = []

	for i in range(turret_count):
		var placed = false
		for attempt in range(max_attempts_per_turret):
			# Elegir una altura por encima del jugador en un rango
			var y = player.global_position.y - randf_range(min_height_above_player, max_height_above_player)
			var x = randf_range(x_min, x_max)
			var candidate = Vector2(x, y)
			# Asegurar que esté por encima del player
			if candidate.y >= player.global_position.y:
				continue
			# Comprobar distancia mínima con otras torres
			var ok = true
			for pos in placed_positions:
				if pos.distance_to(candidate) < min_distance_between_turrets:
					ok = false
					break
			if not ok:
				continue
			# Instanciar la torre
			var turret = turret_scene.instantiate()
			add_child(turret)
			turret.global_position = candidate
			placed_positions.append(candidate)
			placed = true
			break
		# si no se pudo colocar tras varios intentos, la siguiente torre se colocará con separación mínima automática
		if not placed:
			# colocar en una posición determinista intentando distribuirlas
			var fallback_x = lerp(x_min, x_max, float(i) / max(1, turret_count - 1))
			var fallback_y = player.global_position.y - min_height_above_player
			var turret_fb = turret_scene.instantiate()
			add_child(turret_fb)
			turret_fb.global_position = Vector2(fallback_x, fallback_y)
			placed_positions.append(turret_fb.global_position)

	# Opcional: imprimir posiciones para debugging
	#print("Torres colocadas:", placed_positions)
