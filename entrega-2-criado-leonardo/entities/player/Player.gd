extends Sprite2D

var speed = 200 #Pixeles
@onready var cannon = $Cañon

func _physics_process(delta):
	# Rotación del cañón hacia el mouse
	var mouse_position:Vector2 = get_global_mouse_position()
	cannon.look_at(mouse_position)
	#var angle = (mouse_position - cannon.global_position).angle()
	
	# Movimiento horizontal del jugador
	var direction:int = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	position.x += direction * speed * delta
