extends PlayerState



## ID del estado. Debe de ser único entre todos los estados


# Inicializa el estado. Por ej, cambiar la animación¿
func enter() -> void:
	pass


# Limpia el estado. Por ej, reiniciar valores de variables o detener timers
func exit() -> void:
	pass


# Callback derivado de _input
func handle_input(event: InputEvent) -> void:
	pass


# Callback derivado de _physics_process
func update(delta: float) -> void:
	pass


func _on_animation_finished(anim_name: StringName) -> void:
	pass


# Callback genérico para eventos manejados como strings.
func handle_event(event: StringName, value = null) -> void:
	pass
