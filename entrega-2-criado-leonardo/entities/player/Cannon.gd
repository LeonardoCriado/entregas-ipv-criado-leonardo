extends Sprite2D

@onready var fire_position:Marker2D = $FirePosition

@export var projectile_scene:PackedScene

var projectile_container:Node

func fire():
	var projectile_instance:Projectile = projectile_scene.instantiate()
	projectile_container.add_child(projectile_instance)
	projectile_instance.set_
	
