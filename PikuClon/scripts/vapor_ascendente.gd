extends Area2D

@export var velocidad_ascenso: float = -480.0
@export var aceleracion_vapor: float = 2000.0

var _cuerpos_dentro: Array[CharacterBody2D] = []
var _tiempo: float = 0.0

@onready var visual: Sprite2D = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(delta: float) -> void:
	_tiempo += delta
	visual.scale.x = 1.0 + sin(_tiempo * 4.5) * 0.08
	visual.position.y = sin(_tiempo * 6.0) * 6.0

	for cuerpo in _cuerpos_dentro:
		if is_instance_valid(cuerpo):
			cuerpo.velocity.y = move_toward(cuerpo.velocity.y, velocidad_ascenso, aceleracion_vapor * delta)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and not _cuerpos_dentro.has(body):
		_cuerpos_dentro.append(body as CharacterBody2D)


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D and _cuerpos_dentro.has(body):
		_cuerpos_dentro.erase(body as CharacterBody2D)
