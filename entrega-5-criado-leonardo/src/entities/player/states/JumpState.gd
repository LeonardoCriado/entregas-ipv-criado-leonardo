extends PlayerState


func _ready() -> void:
	pass


# Inicializa el estado. Por ej, cambiar la animación
func enter() -> void:
	character.velocity.y -= character.jump_speed
	character._play_animation("jump")



# Limpia el estado. Por ej, reiniciar valores de variables o detener timers
func exit() -> void:
	pass


# Callback derivado de _input
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump") && character.is_on_floor():
		finished.emit("jump")


# Callback derivado de _physics_process
func update(delta: float) -> void:
	character._handle_weapon_actions()
	character._handle_move_input(delta)
	if character.h_movement_direction == 0:
		character._handle_deacceleration(delta)
	character._apply_movement(delta)
	if character.is_on_floor():
		if character.h_movement_direction == 0:
			finished.emit(&"idle")
		else:
			finished.emit(&"walk")
	else:
		if character.velocity.y > 0:
			character._play_animation(&"fall")
		else:
			character._play_animation(&"jump")


# Callback cuando finaliza una animación en tiempo del estado actual
func _on_animation_finished(anim_name: StringName) -> void:
	pass


# Callback genérico para eventos manejados como strings.
func handle_event(event: StringName, value = null) -> void:
	match event:
		&"hit":
			character._handle_hit(value)
			if character.dead:
				finished.emit(&"dead")
