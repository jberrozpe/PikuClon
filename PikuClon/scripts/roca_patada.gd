extends StaticBody2D
## Roca que bloquea el paso y se rompe con una patada normal o voladora.

@export var color_trozos: Color = Color("8c84a0")

var _rota: bool = false


func recibir_patada(_tipo: String) -> void:
	if _rota:
		return
	_rota = true
	Efectos.trozos(global_position, color_trozos, 12, 150.0)
	Efectos.anillo(global_position, color_trozos.lightened(0.3), 110.0, 6.0, 0.5)
	Efectos.destello(global_position, Color(1, 1, 1, 0.9), 36.0)
	if has_node("Sonido"):
		$Sonido.play()
	var colision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if colision != null:
		colision.set_deferred("disabled", true)
	queue_free()
