extends Node2D

@export var altura_apertura: float = 140.0
@export var velocidad_apertura: float = 6.0
@export var abierta_por_defecto: bool = false
@export var mantener_abierta_si_estrella: bool = false

var esta_abierta: bool = false
var _posicion_cerrada: Vector2 = Vector2.ZERO
var _posicion_abierta: Vector2 = Vector2.ZERO

@onready var cuerpo_puerta: AnimatableBody2D = $CuerpoPuerta
@onready var sonido_puerta: AudioStreamPlayer2D = $SonidoPuerta


func _ready() -> void:
	_posicion_cerrada = cuerpo_puerta.position
	_posicion_abierta = _posicion_cerrada + Vector2(0.0, -altura_apertura)
	esta_abierta = abierta_por_defecto or (mantener_abierta_si_estrella and GameState.estrella_recogida)
	if esta_abierta:
		cuerpo_puerta.position = _posicion_abierta


func _physics_process(delta: float) -> void:
	var objetivo := _posicion_abierta if esta_abierta else _posicion_cerrada
	var factor := clampf(velocidad_apertura * delta, 0.0, 1.0)
	cuerpo_puerta.position = cuerpo_puerta.position.lerp(objetivo, factor)


func abrir() -> void:
	if not esta_abierta:
		esta_abierta = true
		sonido_puerta.play()


func cerrar() -> void:
	esta_abierta = false


func establecer_abierta(abierta: bool) -> void:
	esta_abierta = abierta
