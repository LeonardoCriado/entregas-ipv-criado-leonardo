extends CanvasLayer

@export var score_multiplier: float = 1.0
@export var show_milliseconds: bool = false

var elapsed_time: float = 0.0
@onready var score_label: Label = $Stats/ScoreLabel
@onready var health_label: Label = $Stats/HealthLabel
var player: Node = null

func _ready() -> void:
	# Buscar jugador en la escena principal
	var main_scene = get_tree().current_scene
	if main_scene:
		player = main_scene.find_child("Player", true, false)
	_update_labels()

func _process(delta: float) -> void:
	elapsed_time += delta
	_update_labels()

func _update_labels() -> void:
	# Score basado en tiempo transcurrido
	var score = int(elapsed_time * score_multiplier)
	if show_milliseconds:
		# Mostrar segundos con 1 decimal
		score_label.text = "Score: %.1f" % elapsed_time
	else:
		score_label.text = "Score: %d" % score

	# Porcentaje de vida restante
	if player:
		var max_h = player.get("max_health")
		var cur_h = player.get("current_health")
		if typeof(max_h) == TYPE_INT or typeof(max_h) == TYPE_FLOAT:
			if max_h > 0 and typeof(cur_h) in [TYPE_INT, TYPE_FLOAT]:
				var pct = int((float(cur_h) / float(max_h)) * 100.0)
				health_label.text = "Life: %d%%" % pct
				return
		health_label.text = "Life: N/A"
	else:
		health_label.text = "Life: N/A"
