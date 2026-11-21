extends Node2D

const DIALOGO_INICIAL: Array[String] = [
	"¡Uuuh-aaah! Qué calentita está el agua termal... ¡Bienvenido a Japón!",
	"Se me cayó mi Onigiri en las rocas del volcán, allá arriba en el primer vapor.",
	"Si flotas por las nubes de vapor y me lo traes, ¡te regalo una Banda Ninja y unas Gafas Estrella!"
]

const DIALOGO_ESPERANDO: Array[String] = [
	"Métete en la nube de vapor ascendente para subir a por mi Onigiri... ¡yo sigo en remojo!"
]

const DIALOGO_FINAL: Array[String] = [
	"¡Ñam, ñam! ¡Delicioso Onigiri volcánico!",
	"Aquí tienes la Banda Ninja y las Gafas Estrella para tu Armario (pulsa C o Tab)."
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
	visual.scale.y = 1.0 + sin(_tiempo * 2.8) * 0.03


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar_dialogo()


func _avanzar_dialogo() -> void:
	if not bocadillo.visible:
		if GameState.mono_completado:
			_frases_actuales = ["¡Qué relax! ¡Con esa Banda Ninja pareces un maestro del volcán!"]
			_tipo_dialogo = "completado"
		elif GameState.onigiri_recogido:
			_frases_actuales = DIALOGO_FINAL
			_tipo_dialogo = "final"
		elif GameState.hablo_con_mono:
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
			GameState.registrar_charla_mono()
		elif _tipo_dialogo == "final":
			GameState.completar_mono()


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
