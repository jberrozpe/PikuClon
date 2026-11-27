extends StaticBody2D
## Jarrón que esconde un sello y se rompe de una patada.

@export var guarda_sello: bool = true

var _roto: bool = false


func recibir_patada(_tipo: String) -> void:
	if _roto:
		return
	_roto = true
	Efectos.trozos(global_position, Color(0.85, 0.55, 0.32), 10, 130.0)
	Efectos.chispas(global_position, Color(0.95, 0.7, 0.4), 12, 90.0, 0.5)
	if guarda_sello:
		GameState.recoger_sello()
		Efectos.destello(global_position + Vector2(0, -14), Color(1.0, 0.88, 0.4), 46.0)
	queue_free()
