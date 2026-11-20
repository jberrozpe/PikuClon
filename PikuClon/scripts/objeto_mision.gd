extends Area2D

@export var amplitud_flotacion: float = 5.0
@export var velocidad_flotacion: float = 3.5

var _tiempo: float = 0.0
var _y_inicial: float = 0.0

@onready var visual: Node2D = $Visual


func _ready() -> void:
	if GameState.estrella_recogida:
		queue_free()
		return
	_y_inicial = visual.position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_tiempo += delta
	visual.position.y = _y_inicial + sin(_tiempo * velocidad_flotacion) * amplitud_flotacion
	visual.rotation = sin(_tiempo * 2.0) * 0.12


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		GameState.recoger_estrella()
		queue_free()
