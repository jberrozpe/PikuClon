extends Node2D
## Reflejo brillante del sol sobre un jarrón, de vez en cuando.

@export var intervalo: float = 2.8
@export var alto: float = 20.0

var _espera: float = 0.0


func _ready() -> void:
	_espera = randf() * intervalo


func _process(delta: float) -> void:
	_espera -= delta
	if _espera > 0.0:
		return
	_espera = intervalo
	Efectos.destello(global_position + Vector2(0, -alto), Color(1.0, 0.97, 0.78), 18.0)
	Efectos.chispas(global_position + Vector2(0, -alto), Color(1.0, 0.95, 0.7), 3, 36.0, 0.4)
