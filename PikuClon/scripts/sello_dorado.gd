extends Area2D
## Sello de oro del jeque: uno de los tres que perdió en el desierto.

var _recogido: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _recogido or not (body is CharacterBody2D):
		return
	_recogido = true
	GameState.recoger_sello()
	Efectos.destello(global_position, Color(1.0, 0.88, 0.4), 42.0)
	Efectos.chispas(global_position, Color(1.0, 0.92, 0.55), 14, 110.0, 0.6)
	queue_free()
