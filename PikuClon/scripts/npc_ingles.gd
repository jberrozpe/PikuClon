extends Node2D

const DIALOGO_INICIAL: Array[String] = [
	"¡Caramba! ¡Buenas tardes! Soy Sir Reginald.",
	"Mi oveja redonda se ha escapado rodando por la campiña. ¡Es demasiado esférica!",
	"¿Sería tan amable de patearla suavemente hasta el redil de madera? Le regalaré mi Bombín y unos Guantes Blancos."
]

const DIALOGO_ESPERANDO: Array[String] = [
	"Mi oveja sigue rodando por ahí a la derecha. ¡Métala en el redil, por favor!"
]

const DIALOGO_FINAL: Array[String] = [
	"¡Espléndido! ¡Qué técnica de patada tan distinguida!",
	"Aquí tiene su Bombín británico y sus Guantes Blancos para el Armario (pulse C o Tab)."
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
		if GameState.ingles_completado:
			_frases_actuales = ["¡Cheerio! El Bombín y los Guantes Blancos le sientan como a un auténtico lord."]
			_tipo_dialogo = "completado"
		elif GameState.oveja_en_redil:
			_frases_actuales = DIALOGO_FINAL
			_tipo_dialogo = "final"
		elif GameState.hablo_con_ingles:
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
			GameState.registrar_charla_ingles()
		elif _tipo_dialogo == "final":
			GameState.completar_ingles()


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
