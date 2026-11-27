extends Area2D
## Bicho de cueva: pasea, quita una vida al tocarlo y muere de una patada.

@export var velocidad: float = 46.0
@export var limite_izquierdo: float = -120.0
@export var limite_derecho: float = 120.0
@export var quita_vida: bool = true

var _origen: float = 0.0
var _direccion: float = 1.0
var _vivo: bool = true


func _ready() -> void:
	_origen = position.x
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not _vivo:
		return
	position.x += _direccion * velocidad * delta
	if position.x > _origen + limite_derecho:
		_direccion = -1.0
	elif position.x < _origen + limite_izquierdo:
		_direccion = 1.0
	if has_node("Visual"):
		$Visual.scale.x = absf($Visual.scale.x) * _direccion


func _on_body_entered(body: Node2D) -> void:
	if not _vivo or not quita_vida:
		return
	if body.has_method("recibir_dano"):
		body.recibir_dano(global_position)


func recibir_patada(_tipo: String) -> void:
	if not _vivo:
		return
	_vivo = false
	Efectos.trozos(global_position, Color(0.75, 0.3, 0.2), 10, 120.0)
	Efectos.chispas(global_position, Color(0.9, 0.6, 0.3), 12, 90.0, 0.5)
	queue_free()
