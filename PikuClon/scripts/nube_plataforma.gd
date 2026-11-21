extends AnimatableBody2D

@export var desplazamiento: Vector2 = Vector2(0.0, -50.0)
@export var velocidad: float = 1.6
@export var desfase_inicial: float = 0.0

var _posicion_inicial: Vector2 = Vector2.ZERO
var _tiempo: float = 0.0
var _rebote_y: float = 0.0

@onready var visual: Sprite2D = $Visual
@onready var detector_pisar: Area2D = $DetectorPisar


func _ready() -> void:
	_posicion_inicial = position
	_tiempo = desfase_inicial
	detector_pisar.body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_tiempo += delta * velocidad
	var factor := (1.0 - cos(_tiempo)) * 0.5
	position = _posicion_inicial + desplazamiento * factor

	_rebote_y = lerpf(_rebote_y, 0.0, clampf(12.0 * delta, 0.0, 1.0))
	visual.position.y = _rebote_y
	visual.scale = visual.scale.lerp(Vector2.ONE, clampf(12.0 * delta, 0.0, 1.0))


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_rebote_y = 6.0
		visual.scale = Vector2(1.12, 0.82)
