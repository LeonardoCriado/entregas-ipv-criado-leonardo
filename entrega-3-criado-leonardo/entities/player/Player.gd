extends CharacterBody2D

@onready var cannon: Node = $Cannon

@export var ACCELERATION: float = 20.0
@export var H_SPEED_LIMIT: float = 600.0
@export var FRICTION_WEIGHT: float = 0.1
@export var JUMP_SPEED: float = -50
@export var GRAVITY: float = 2

var projectile_container: Node

func initialize(projectile_container: Node) -> void:
	self.projectile_container = projectile_container
	cannon.projectile_container = projectile_container

func _physics_process(delta: float) -> void:
	_handle_input()
	_apply_movement(delta)
	_update_cannon()
	velocity.y += GRAVITY

# -------------------------------
# Sección de Input
# -------------------------------
func _handle_input() -> void:
	if Input.is_action_just_pressed("fire_cannon"):
		_fire_cannon()
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_SPEED

# -------------------------------
# Sección de Movimiento/Física
# -------------------------------
func _apply_movement(delta: float) -> void:
	var h_dir: int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	var velocity = self.velocity

	if h_dir != 0:
		velocity.x = clamp(
			velocity.x + (h_dir * ACCELERATION),
			-H_SPEED_LIMIT,
			H_SPEED_LIMIT
		)
	else:
		# freno progresivo con lerp
		velocity.x = lerp(velocity.x, 0.0, FRICTION_WEIGHT) if abs(velocity.x) > 1.0 else 0.0

	self.velocity = velocity
	move_and_slide()

# -------------------------------
# Sección de Cañón
# -------------------------------
func _update_cannon() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)

func _fire_cannon() -> void:
	if projectile_container == null:
		projectile_container = get_parent()
		cannon.projectile_container = projectile_container
	cannon.fire()
