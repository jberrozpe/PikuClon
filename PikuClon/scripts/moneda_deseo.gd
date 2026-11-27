extends Area2D
## Moneda de deseo: el genio las perdió por la cueva.

var _recogida: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _recogida or not (body is CharacterBody2D):
		return
	_recogida = true
	GameState.recoger_deseo()
	Efectos.destello(global_position, Color(1.0, 0.85, 0.35), 44.0)
	Efectos.chispas(global_position, Color(1.0, 0.9, 0.5), 16, 110.0, 0.6)
	if has_node("Sonido"):
		$Sonido.play()
	queue_free()
