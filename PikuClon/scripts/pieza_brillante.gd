extends Area2D

@export_enum("austria", "selva_negra") var zona_pieza: String = "austria"

var _recogida: bool = false
var _tiempo: float = 0.0

@onready var visual: Sprite2D = $Visual
@onready var sonido: AudioStreamPlayer = $SonidoRecoger


func _ready() -> void:
	var ya_recogida := GameState.pieza_austria_recogida if zona_pieza == "austria" else GameState.pieza_selva_recogida
	if ya_recogida:
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
	if zona_pieza == "austria":
		GameState.recoger_pieza_austria()
	else:
		GameState.recoger_pieza_selva()
	visual.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	sonido.play()
	await sonido.finished
	queue_free()
