extends Node2D

@export var fuerza_rebote_jugador: float = -760.0
@export var impulso_objeto: float = -540.0

@onready var visual: Sprite2D = $Visual
@onready var detector: Area2D = $DetectorSalto
@onready var sonido: AudioStreamPlayer2D = $SonidoRebote


func _ready() -> void:
	detector.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	visual.scale = visual.scale.lerp(Vector2.ONE, clampf(12.0 * delta, 0.0, 1.0))


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		(body as CharacterBody2D).velocity.y = fuerza_rebote_jugador
		_animar_y_sonar()
	elif body is RigidBody2D:
		(body as RigidBody2D).apply_central_impulse(Vector2(0.0, impulso_objeto))
		_animar_y_sonar()


func _animar_y_sonar() -> void:
	visual.scale = Vector2(1.26, 0.72)
	if sonido:
		sonido.play()
