extends Node2D

const DIALOGO_INICIAL: Array[String] = [
	"¡Socorro! ¡Mi tortuga de carreras, Rayo, se ha escapado por toda la habitación!",
	"Ya sé que parece una pelota roja normal, pero es una bestia rapidísima y muy feroz.",
	"¿Puedes darle un par de patadas suaves para meterla otra vez en su caja?"
]

const DIALOGO_ESPERANDO: Array[String] = [
	"¿Todavía no has atrapado a Rayo? ¡Ten cuidado, corre a la velocidad de la luz!",
	"Bueno, en realidad está quietísima, pero yo me pongo muy nervioso igual."
]

const DIALOGO_FINAL: Array[String] = [
	"¡SÍ! ¡Has domado a la bestia! Rayo vuelve a estar a salvo en su hogar.",
	"Eres la persona más valiente y con mejores patadas que he conocido hoy.",
	"Toma esta medalla invisible como premio... ¡cuidado, que pesa un montón!"
]

var _jugador_cerca: bool = false
var _tiempo: float = 0.0
var _frases_actuales: Array[String] = []
var _indice_frase: int = 0
var _tipo_dialogo_actual: String = ""

@onready var cuerpo_visual: Node2D = $CuerpoVisual
@onready var pierna_izq: Line2D = $CuerpoVisual/PiernaIzq
@onready var pierna_der: Line2D = $CuerpoVisual/PiernaDer
@onready var cuerpo_sprite: Sprite2D = $CuerpoVisual/CuerpoSprite
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
	# Patas largas y finitas como fideos que siempre tiemblan un poco
	var temblor_izq := sin(_tiempo * 28.0) * 2.2
	var temblor_der := cos(_tiempo * 33.0) * 2.2
	pierna_izq.set_point_position(1, Vector2(-1.5 + temblor_izq, 18.0))
	pierna_der.set_point_position(1, Vector2(1.5 + temblor_der, 18.0))
	cuerpo_sprite.position.y = -76.0 + sin(_tiempo * 5.0) * 1.5


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar_dialogo()


func _avanzar_dialogo() -> void:
	if not bocadillo.visible:
		if GameState.rayo_en_caja:
			_frases_actuales = DIALOGO_FINAL
			_tipo_dialogo_actual = "final"
		elif GameState.hablo_con_quesito:
			_frases_actuales = DIALOGO_ESPERANDO
			_tipo_dialogo_actual = "esperando"
		else:
			_frases_actuales = DIALOGO_INICIAL
			_tipo_dialogo_actual = "inicial"

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
		if _tipo_dialogo_actual == "inicial":
			GameState.registrar_charla_quesito()
		elif _tipo_dialogo_actual == "final":
			GameState.completar_mision_quesito()


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
