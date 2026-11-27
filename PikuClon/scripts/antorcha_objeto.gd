extends Area2D
## Antorcha que se puede recoger y llevar en el armario.

var _recogida: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _recogida or not (body is CharacterBody2D):
		return
	_recogida = true
	GameState.desbloquear_accesorio("lampara", "antorcha")
	Efectos.destello(global_position, Color(1.0, 0.7, 0.3), 50.0)
	Efectos.chispas(global_position, Color(1.0, 0.8, 0.4), 16, 110.0, 0.6)
	queue_free()
