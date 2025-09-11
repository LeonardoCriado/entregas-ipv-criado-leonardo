extends Sprite2D

@onready var fire_position: Node2D = $FirePosition
@onready var fire_timer: Timer = $FireTimer
@export var projectile_scene: PackedScene

var projectile_container: Node
var targuet:Node2D

func _ready() -> void:
	fire_timer.timeout.connect(fire_at_player)

func initialize(turret_pos: Vector2, projectile_container: Node) -> void:
	global_position = turret_pos
	self.projectile_container = projectile_container


func fire_at_player() -> void:
	var proj_instance = projectile_scene.instantiate()
	proj_instance.initialize(
		projectile_container,
		fire_position.global_position,
		fire_position.global_position.direction_to(targuet.global_position)
	)
	print(fire_position.position.direction_to(targuet.position))


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Player")  
	print(body.global_position)
	if body is Player:
		targuet = body
		fire_timer.start()
