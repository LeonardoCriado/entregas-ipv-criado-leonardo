extends Sprite2D

var speed = 200 #Pixeles
var projectile_container:Node
@onready var cannon = $Cannon

func set_projectile_container(container:Node):
	cannon.projectile_container =  container
	projectile_container = container

func _physics_process(delta):
	# Rotación del cañón hacia el mouse
	var mouse_position:Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)
	#var angle = (mouse_position - cannon.global_position).angle()
	
	# Movimiento horizontal del jugador
	var direction:int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	position.x += direction * speed * delta
	
	#Logica de disparo
	if Input.is_action_just_pressed("fire"):
		cannon.fire()
