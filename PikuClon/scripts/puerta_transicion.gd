extends Area2D

@export_file("*.tscn") var escena_destino: String = ""
@export var punto_aparicion_destino: String = ""
@export var requerir_tecla: bool = false
@export var texto_indicador: String = "[E] Entrar"

var _jugador_dentro: bool = false
var _puede_activar: bool = false

@onready var indicador: Label = $Indicador


func _ready() -> void:
	indicador.text = texto_indicador
	indicador.visible = false
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	await get_tree().create_timer(0.35).timeout
	_puede_activar = true


func _unhandled_input(event: InputEvent) -> void:
	if not requerir_tecla or not _jugador_dentro or not _puede_activar:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_cambiar_de_escena()


func _on_body_entered(body: Node2D) -> void:
	if not _puede_activar or not (body is CharacterBody2D):
		return
	_jugador_dentro = true
	if requerir_tecla:
		indicador.visible = true
	else:
		_cambiar_de_escena()


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_dentro = false
		indicador.visible = false


func _cambiar_de_escena() -> void:
	if escena_destino.is_empty():
		return
	_puede_activar = false
	GameState.ir_a_escena(escena_destino, punto_aparicion_destino)
