extends Area2D

var _recogida: bool = false
var _tiempo: float = 0.0

@onready var visual: Sprite2D = $Visual
@onready var sonido: AudioStreamPlayer = $SonidoRecoger


func _ready() -> void:
	if GameState.pieza_austria_recogida:
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_tiempo += delta
	visual.position.y = sin(_tiempo * 3.5) * 6.0
	visual.rotation = sin(_tiempo * 2.0) * 0.14


func _on_body_entered(body: Node2D) -> void:
	if _recogida or not (body is CharacterBody2D):
		return
	_recogida = true
	GameState.recoger_pieza_austria()
	visual.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	sonido.play()
	await sonido.finished
	queue_free()
