extends Node2D
## Caravana: grupo de camellos que avanza junto de un lado a otro.

@export var velocidad: float = 14.0
@export var recorrido: float = 220.0

var _x0: float = 0.0
var _t: float = 0.0
var _dir: float = 1.0
var _polvo: float = 0.0


func _ready() -> void:
	_x0 = position.x
	_t = randf() * 4.0
	for hijo in get_children():
		if hijo is Sprite2D:
			hijo.set_meta("y0", hijo.position.y)


func _process(delta: float) -> void:
	_t += delta
	position.x += _dir * velocidad * delta
	if position.x > _x0 + recorrido:
		position.x = _x0 + recorrido
		_dir = -1.0
	elif position.x < _x0 - recorrido:
		position.x = _x0 - recorrido
		_dir = 1.0
	for i in range(get_child_count()):
		var hijo := get_child(i) as Sprite2D
		if hijo != null:
			hijo.flip_h = _dir < 0.0
			hijo.position.y = hijo.get_meta("y0", 0.0) - absf(sin(_t * 2.6 + i * 0.7)) * 1.6
	_polvo -= delta
	if _polvo <= 0.0:
		_polvo = 0.5
		Efectos.chispas(global_position + Vector2(-_dir * 120.0, 6.0),
				Color(0.86, 0.76, 0.58, 0.7), 3, 24.0, 0.6)
