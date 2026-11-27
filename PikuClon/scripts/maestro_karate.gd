extends Node2D
## Maestro de karate del nivel de Japón.
##
## Enseña dos lecciones por misiones:
##   1) Romper 3 tablones a patadas  -> desbloquea el DOBLE SALTO.
##   2) Golpear 3 dianas en el aire  -> desbloquea la PATADA VOLADORA.

const DIALOGO_INICIAL: Array[String] = [
	"Mmm... huelo a valentía. Y a onigiri. Sobre todo a onigiri.",
	"Soy el Maestro Kimono. Llevo 40 años enseñando karate... y 39 echándome la siesta.",
	"Tu patada es decente, pero tu salto parece el de una tortuga con reuma.",
	"Lección 1: rompe los 3 tablones del patio con tu patada (E o Espacio). ¡Sin miedo!",
]

const DIALOGO_TABLONES: Array[String] = [
	"¡Los tablones, saltamontes! Los de madera del patio. A mí no, por favor.",
	"Si te cuesta, grita «¡KIAAA!». No sirve de nada, pero anima mucho.",
]

const DIALOGO_DOBLE_SALTO: Array[String] = [
	"¡JA! ¡Tres tablones! Mi abuela rompe cuatro, pero ella juega en otra liga.",
	"Ahora te enseño el legendario Salto de la Nube Doble.",
	"Consiste en saltar... dos veces. Sí, ya sé que suena obvio: mis alumnos siempre lo intentan una sola vez y luego lloran.",
	"¡Pulsa saltar (W) otra vez en el aire! El universo te regalará una voltereta.",
]

const DIALOGO_DIANAS: Array[String] = [
	"Lección 2: la Patada Voladora. Es como una patada normal, pero con más drama.",
	"Golpea las 3 dianas del jardín de la derecha... ¡en el aire!",
	"Salta, salta otra vez y patea (E) mientras vuelas. Y pon cara de tigre: es importante.",
]

const DIALOGO_PATADA: Array[String] = [
	"¡PERFECTO! Esa patada ha hecho temblar el volcán. O quizá era el volcán. Da igual.",
	"Ya eres oficialmente un karateka de verdad. O al menos uno que salta dos veces.",
	"Recuerda, joven blob: el verdadero poder no está en la patada... está en el onigiri de después.",
]

const DIALOGO_FINAL: Array[String] = [
	"¿Otra vez por aquí? El dojo siempre está abierto. Y la siesta también.",
	"Practica tus movimientos: doble salto y patada voladora. El mundo es tu tatami.",
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
@onready var etiqueta_nombre: Label = $Bocadillo/Nombre
@onready var sonido_hablar: AudioStreamPlayer2D = $SonidoHablar
@onready var sonido_exito: AudioStreamPlayer = $SonidoExito


func _ready() -> void:
	indicador.visible = false
	TemaUI.vistir_indicador(indicador, TemaUI.ROSA)
	bocadillo.visible = false
	GameState.dialogo_abierto = false
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)
	TemaUI.aplicar(bocadillo)
	TemaUI.vistir_bocadillo(bocadillo, TemaUI.NARANJA)


func _process(delta: float) -> void:
	_tiempo += delta
	# Respira y se balancea como una montaña sabia... y un poco dormida.
	visual.scale.y = 1.0 + sin(_tiempo * 2.2) * 0.035
	visual.rotation = sin(_tiempo * 1.1) * 0.02


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar_dialogo()


func _avanzar_dialogo() -> void:
	if not bocadillo.visible:
		var guion := _elegir_guion()
		_frases_actuales = guion["frases"]
		_tipo_dialogo = guion["tipo"]
		_indice_frase = 0
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		bocadillo.visible = true
		GameState.dialogo_abierto = true
		indicador.visible = false
		sonido_hablar.play()
		return

	_indice_frase += 1
	if _indice_frase < _frases_actuales.size():
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		sonido_hablar.play()
	else:
		bocadillo.visible = false
		GameState.dialogo_abierto = false
		indicador.visible = true
		_cerrar_dialogo()


func _elegir_guion() -> Dictionary:
	if not GameState.hablo_con_maestro:
		return {"frases": DIALOGO_INICIAL, "tipo": "inicial"}

	if not GameState.leccion_doble_salto_completada:
		if GameState.tablones_rotos >= GameState.TABLONES_MISION:
			return {"frases": DIALOGO_DOBLE_SALTO, "tipo": "aprender_doble"}
		return {"frases": DIALOGO_TABLONES, "tipo": "tablones"}

	if not GameState.leccion_patada_completada:
		if GameState.dianas_golpeadas >= GameState.DIANAS_MISION:
			return {"frases": DIALOGO_PATADA, "tipo": "aprender_patada"}
		return {"frases": DIALOGO_DIANAS, "tipo": "dianas"}

	return {"frases": DIALOGO_FINAL, "tipo": "final"}


func _cerrar_dialogo() -> void:
	match _tipo_dialogo:
		"inicial":
			GameState.registrar_charla_maestro()
		"aprender_doble":
			GameState.completar_leccion_doble_salto()
			_celebrar(Color(1.0, 0.86, 0.42))
		"aprender_patada":
			GameState.completar_leccion_patada_voladora()
			_celebrar(Color(0.55, 0.9, 1.0))


func _celebrar(color: Color) -> void:
	sonido_exito.play()
	var centro := global_position + Vector2(0, -56)
	Efectos.anillo(centro, color, 150.0, 6.0, 0.8)
	Efectos.destello(centro, Color(1, 1, 1, 0.95), 46.0)
	Efectos.chispas(centro, color, 22, 130.0, 0.8)


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
		GameState.dialogo_abierto = false
