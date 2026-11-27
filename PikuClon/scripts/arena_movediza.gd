extends Area2D
## Arenas movedizas: frenan al jugador y lo arrastran hacia abajo mientras
## esté dentro.

var _cuerpos: Array[Node2D] = []
var _tiempo: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_tiempo += delta
	for cuerpo in _cuerpos:
		if cuerpo is CharacterBody2D:
			var jugador := cuerpo as CharacterBody2D
			jugador.velocity.x = move_toward(jugador.velocity.x, 0.0, 1500.0 * delta)
			jugador.velocity.y += 190.0 * delta
	# Burbujas de arena
	if _tiempo > 0.32 and not _cuerpos.is_empty():
		_tiempo = 0.0
		Efectos.chispas(global_position + Vector2(randf_range(-70.0, 70.0), -4.0),
				Color(0.86, 0.71, 0.38), 4, 26.0, 0.45)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not _cuerpos.has(body):
		_cuerpos.append(body)


func _on_body_exited(body: Node2D) -> void:
	_cuerpos.erase(body)
