extends Node2D

@export_multiline var dialogo_inicial: String = "¡Hola! ¿Puedes cruzar esa puerta y traerme la estrella?"
@export_multiline var dialogo_esperando: String = "Empuja o patea la caja sobre el botón rojo para abrir la puerta."
@export_multiline var dialogo_estrella_recogida: String = "¡Muchas gracias por traerme la estrella! ¡Eres un héroe!"
@export_multiline var dialogo_completado: String = "¡Gracias otra vez por tu ayuda, amigo!"

var _jugador_cerca: bool = false
var _tiempo: float = 0.0

@onready var cuerpo_visual: Node2D = $CuerpoVisual
@onready var zona_interaccion: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var bocadillo: Control = $Bocadillo
@onready var texto_bocadillo: Label = $Bocadillo/Texto
@onready var sonido_hablar: AudioStreamPlayer2D = $SonidoHablar


func _ready() -> void:
	indicador.visible = false
	bocadillo.visible = false
	zona_interaccion.body_entered.connect(_on_body_entered)
	zona_interaccion.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_tiempo += delta
	cuerpo_visual.scale.y = 1.0 + sin(_tiempo * 3.2) * 0.03


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_alternar_dialogo()


func _alternar_dialogo() -> void:
	if bocadillo.visible:
		bocadillo.visible = false
		indicador.visible = true
		return

	if GameState.mision_completada:
		texto_bocadillo.text = dialogo_completado
	elif GameState.estrella_recogida:
		texto_bocadillo.text = dialogo_estrella_recogida
		GameState.completar_mision()
	elif GameState.hablo_con_npc:
		texto_bocadillo.text = dialogo_esperando
	else:
		texto_bocadillo.text = dialogo_inicial
		GameState.registrar_charla_npc()

	bocadillo.visible = true
	indicador.visible = false
	sonido_hablar.play()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = true
		if not bocadillo.visible:
			indicador.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = false
		indicador.visible = false
		bocadillo.visible = false
