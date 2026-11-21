extends Node2D

const DIALOGO_INICIAL: Array[String] = [
	"¡Muuu! ¡Hola, viajero! Bienvenido a los Alpes Austríacos.",
	"Si subes por las nubes saltarinas hasta la cima encontrarás una Pieza Brillante.",
	"Y si de paso recoges la Flor Edelweiss especial del saliente medio, ¡te regalo mi Sombrero Tirolés!"
]

const DIALOGO_ESPERANDO: Array[String] = [
	"¡Muuu! La Flor Edelweiss está en la plataforma de la izquierda, subiendo por las primeras nubes."
]

const DIALOGO_FINAL: Array[String] = [
	"¡Muuu-chas gracias! ¡Qué Edelweiss tan preciosa!",
	"Aquí tienes el Sombrero Tirolés para tu Armario (pulsa C o Tab para probártelo)."
]

var _jugador_cerca: bool = false
var _tiempo: float = 0.0
var _frases_actuales: Array[String] = []
var _indice_frase: int = 0
var _tipo_dialogo: String = ""

@onready var visual: Sprite2D = $Visual
@onready var zona: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var bocadillo: Control = $Bocadillo
@onready var texto_bocadillo: Label = $Bocadillo/Texto
@onready var sonido_hablar: AudioStreamPlayer2D = $SonidoHablar


func _ready() -> void:
	indicador.visible = false
	bocadillo.visible = false
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_tiempo += delta
	visual.scale.y = 1.0 + sin(_tiempo * 3.0) * 0.03


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar_dialogo()


func _avanzar_dialogo() -> void:
	if not bocadillo.visible:
		if GameState.vaca_completada:
			_frases_actuales = ["¡Muuu! ¡El Sombrero Tirolés te sienta de maravilla!"]
			_tipo_dialogo = "completado"
		elif GameState.flor_vaca_recogida:
			_frases_actuales = DIALOGO_FINAL
			_tipo_dialogo = "final"
		elif GameState.hablo_con_vaca:
			_frases_actuales = DIALOGO_ESPERANDO
			_tipo_dialogo = "esperando"
		else:
			_frases_actuales = DIALOGO_INICIAL
			_tipo_dialogo = "inicial"

		_indice_frase = 0
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		bocadillo.visible = true
		indicador.visible = false
		sonido_hablar.play()
		return

	_indice_frase += 1
	if _indice_frase < _frases_actuales.size():
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		sonido_hablar.play()
	else:
		bocadillo.visible = false
		indicador.visible = true
		if _tipo_dialogo == "inicial":
			GameState.registrar_charla_vaca()
		elif _tipo_dialogo == "final":
			GameState.completar_vaca()


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
