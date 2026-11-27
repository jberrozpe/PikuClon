extends Sprite2D
## Camello decorativo: pasea, se gira, levanta polvo y puede pararse a beber.

@export var velocidad: float = 16.0
@export var recorrido: float = 120.0
@export var balanceo: float = 1.6
@export var bebe_en: float = 1e9

var _x0: float = 0.0
var _y0: float = 0.0
var _t: float = 0.0
var _dir: float = 1.0
var _polvo: float = 0.0
var _bebiendo: float = 0.0


func _ready() -> void:
	_x0 = position.x
	_y0 = position.y
	_t = randf() * 6.0


func _process(delta: float) -> void:
	_t += delta
	if _bebiendo > 0.0:
		_bebiendo -= delta
		rotation = lerp(rotation, deg_to_rad(-7.0), 6.0 * delta)
		position.y = _y0
		if _bebiendo <= 0.0:
			_bebiendo = 0.0
		return

	var antes := position.x
	position.x += _dir * velocidad * delta
	if position.x > _x0 + recorrido:
		position.x = _x0 + recorrido
		_dir = -1.0
	elif position.x < _x0 - recorrido:
		position.x = _x0 - recorrido
		_dir = 1.0
	flip_h = _dir < 0.0
	position.y = _y0 - absf(sin(_t * 3.2)) * 1.8
	rotation = sin(_t * 1.7) * deg_to_rad(balanceo)

	# se para a beber si pasa por el punto de agua
	if bebe_en < 1e8 and antes != position.x:
		if (antes - bebe_en) * (position.x - bebe_en) <= 0.0:
			_bebiendo = 4.0
			Efectos.chispas(global_position + Vector2(_dir * 40.0, 4.0),
					Color(0.62, 0.9, 0.95, 0.8), 6, 40.0, 0.8)

	_polvo -= delta
	if _polvo <= 0.0:
		_polvo = 0.42
		Efectos.chispas(global_position + Vector2(-_dir * 26.0, 6.0),
				Color(0.86, 0.76, 0.58, 0.75), 3, 24.0, 0.55)
