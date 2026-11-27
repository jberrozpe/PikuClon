extends Node2D
## Personaje decorativo: respira y se balancea suavemente.

@export var amplitud: float = 0.03
@export var velocidad: float = 2.0

var _tiempo: float = 0.0
var _escala_base: Vector2 = Vector2.ONE
@onready var visual: Node2D = get_node_or_null("Visual")


func _ready() -> void:
	if visual != null:
		_escala_base = visual.scale


func _process(delta: float) -> void:
	_tiempo += delta
	if visual != null:
		visual.scale.y = _escala_base.y * (1.0 + sin(_tiempo * velocidad) * amplitud)
		visual.rotation = sin(_tiempo * velocidad * 0.5) * 0.012
