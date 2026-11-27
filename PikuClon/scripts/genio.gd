extends Node2D
## Genio de la lámpara: pide tres monedas de deseo y concede el Salto del Genio.

const DIALOGO_INICIAL: Array[String] = [
	"¡Por fin alguien que baja hasta aquí! Soy el Genio de la Lámpara... bueno, lo era.",
	"Me robaron la lámpara y se me cayeron tres Monedas de Deseo por la cueva.",
	"Tráemelas y te concedo el Salto del Genio: un salto más, directo al aire.",
	"Y de paso te dejo llevar la lámpara. Ya no la uso: me da calor en las manos.",
]

const DIALOGO_FALTAN: Array[String] = [
	"Me faltan monedas de deseo. Están por la cueva, brillan bastante.",
]

const DIALOGO_FINAL: Array[String] = [
	"¡Las tres! Un genio de palabra.",
	"Te concedo el Salto del Genio: pulsa salto tres veces y llegarás más alto.",
	"Y aquí tienes la lámpara. Cuídala, que tiene más años que la cueva.",
	"Y un corazón de propina, que la cueva está llena de bichos.",
]

var _jugador_cerca: bool = false
var _tiempo: float = 0.0
var _frases: Array = []
var _indice: int = 0
var _tipo: String = ""
var _escala_base: Vector2 = Vector2.ONE

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var zona: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var bocadillo: Control = $Bocadillo
@onready var texto: Label = $Bocadillo/Texto
@onready var sonido: AudioStreamPlayer2D = $SonidoHablar


func _ready() -> void:
	if visual != null:
		_escala_base = visual.scale
	indicador.visible = false
	bocadillo.visible = false
	TemaUI.vistir_indicador(indicador, TemaUI.AZUL)
	TemaUI.vistir_bocadillo(bocadillo, TemaUI.AZUL)
	zona.body_entered.connect(_on_entra)
	zona.body_exited.connect(_on_sale)


func _process(delta: float) -> void:
	_tiempo += delta
	if visual != null:
		visual.scale = _escala_base * (1.0 + sin(_tiempo * 2.0) * 0.03)
		visual.position.y = sin(_tiempo * 1.6) * 4.0


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if GameState.dialogo_abierto and not bocadillo.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar()


func _avanzar() -> void:
	if not bocadillo.visible:
		if GameState.genio_completado:
			_frases = ["La lámpara es tuya. Y el salto... también. No lo gastes todo de golpe."]
			_tipo = "hecho"
		elif GameState.deseos_recogidos >= 3:
			_frases = DIALOGO_FINAL
			_tipo = "final"
		elif GameState.deseos_recogidos > 0:
			_frases = ["Llevas %d de 3 monedas. Sigue buscando, que la cueva es grande." % GameState.deseos_recogidos]
			_tipo = "faltan"
		else:
			_frases = DIALOGO_INICIAL
			_tipo = "inicial"
		_indice = 0
		texto.text = _frases[_indice]
		bocadillo.visible = true
		_ajustar_bocadillo()
		indicador.visible = false
		GameState.dialogo_abierto = true
		sonido.play()
		return

	_indice += 1
	if _indice < _frases.size():
		texto.text = _frases[_indice]
		sonido.play()
	else:
		bocadillo.visible = false
		indicador.visible = true
		GameState.dialogo_abierto = false
		if _tipo == "final":
			GameState.completar_genio()
			Efectos.destello(global_position, Color(0.6, 0.85, 1.0), 90.0)
			Efectos.anillo(global_position, Color(0.7, 0.9, 1.0), 180.0, 6.0, 0.9)


func _ajustar_bocadillo() -> void:
	var ancho_pantalla := get_viewport_rect().size.x
	var centro := get_global_transform_with_canvas().origin.x
	var medio := 150.0
	var desplazamiento := 0.0
	if centro - medio < 12.0:
		desplazamiento = 12.0 - (centro - medio)
	elif centro + medio > ancho_pantalla - 12.0:
		desplazamiento = (ancho_pantalla - 12.0) - (centro + medio)
	bocadillo.offset_left = -medio + desplazamiento
	bocadillo.offset_right = medio + desplazamiento


func _on_entra(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = true
		if not bocadillo.visible:
			indicador.visible = true


func _on_sale(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = false
		indicador.visible = false
		bocadillo.visible = false
		GameState.dialogo_abierto = false
