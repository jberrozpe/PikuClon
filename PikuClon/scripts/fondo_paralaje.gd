extends Node2D
## Mueve una capa de fondo más despacio que la cámara (paralaje).
## factor = 1 → se mueve con el mundo; 0.3 → el fondo avanza al 30 %.

@export var factor: float = 0.3

var _base_x: float = 0.0
var _iniciado: bool = false


func _process(_delta: float) -> void:
	var camara := get_viewport().get_camera_2d()
	if camara == null:
		return
	if not _iniciado:
		_base_x = position.x
		_iniciado = true
	position.x = _base_x + camara.global_position.x * (1.0 - factor)
