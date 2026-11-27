extends Node2D
## Ráfagas de arena que cruzan el desierto de vez en cuando.

@export var intervalo_min: float = 1.4
@export var intervalo_max: float = 3.6
@export var ancho: float = 1200.0
@export var alto: float = 260.0

var _espera: float = 0.6
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 99
	z_index = 6


func _process(delta: float) -> void:
	_espera -= delta
	if _espera > 0.0:
		return
	_espera = _rng.randf_range(intervalo_min, intervalo_max)
	var camara := get_viewport().get_camera_2d()
	var centro := camara.global_position if camara != null else global_position
	var inicio := centro + Vector2(-ancho * 0.5, _rng.randf_range(-alto, alto))
	for i in range(_rng.randi_range(4, 8)):
		var pos := inicio + Vector2(_rng.randf_range(0.0, 160.0), _rng.randf_range(-30.0, 30.0))
		Efectos.chispas(pos, Color(0.93, 0.83, 0.63, 0.8), 2, 150.0, 0.7)
