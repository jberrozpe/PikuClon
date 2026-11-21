extends Area2D

var _recogida: bool = false

@onready var visual: Node2D = $Visual
@onready var sonido: AudioStreamPlayer = $SonidoRecoger


func _ready() -> void:
	if GameState.bellota_recogida:
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _process(_delta: float) -> void:
	visual.position.y = sin(Time.get_ticks_msec() * 0.004) * 3.5


func _on_body_entered(body: Node2D) -> void:
	if _recogida or not (body is CharacterBody2D):
		return
	_recogida = true
	GameState.recoger_bellota()
	visual.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	sonido.play()
	await sonido.finished
	queue_free()
