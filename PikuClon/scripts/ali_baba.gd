extends Node2D
## Ali Babá: pide abrir la cueva sellada y traer el tesoro.
## Al entregarlo regala el Talismán del Poder (escudo temporal).

const DIALOGO_INICIAL: Array[String] = [
	"¡Soy Ali Babá! Bueno... Ali, el hermano menos famoso. La fama se la llevó el otro.",
	"Mi cueva está sellada por una puerta de piedra que solo se abre con un grito como los del Tíbet.",
	"Si abres la cueva y me traes el tesoro de la sala principal, te daré el Talismán del Poder.",
]

const DIALOGO_SIN_GRITO: Array[String] = [
	"Esa puerta no cede con patadas. Necesitas el Grito Gutural del maestro tibetano.",
	"Ve a las montañas nevadas y vuelve con voz de trueno.",
]

const DIALOGO_CERRADA: Array[String] = [
	"La cueva sigue sellada. Ponte delante de la losa de piedra y grita (Q).",
	"Y avisa antes, que estoy aquí al lado y me he asustado.",
]

const DIALOGO_ABIERTA: Array[String] = [
	"¡Se abrió! Dentro hay un laberinto de piedra con pasadizos muy bajos.",
	"Salta el doble y hazte bola cuando el techo esté bajo. El tesoro brilla al fondo.",
]

const DIALOGO_TESORO: Array[String] = [
	"¡El tesoro! Monedas, joyas... y polvo de tres siglos. Todo cuenta.",
	"Toma el Talismán del Poder: invócalo (T) y te rodeará un escudo protector temporal.",
	"Úsalo con cabeza. Y si ves al otro Ali, no le digas que tengo esto.",
]

const DIALOGO_SELLOS_PIDE: Array[String] = [
	"Escucha, amigo. Se me han perdido tres sellos de oro por el desierto.",
	"Uno está dentro de un jarrón (patea el que tiene la franja azul), otro sobre la roca grande y otro tras la roca del fondo.",
	"Tráemelos y te doy algo mejor que el talismán: un corazón más de vida.",
]

const DIALOGO_SELLOS_FALTAN: Array[String] = [
	"Me faltan sellos todavía. Mira en los jarrones, sobre las rocas y detrás de la formación de la derecha.",
]

const DIALOGO_SELLOS_BIEN: Array[String] = [
	"¡Los tres! Eres más rápido que mi camello.",
	"Toma: un corazón extra. Que te dure, que el desierto es muy largo.",
]

const DIALOGO_FINAL: Array[String] = [
	"Gracias, amigo. Ahora soy rico y, sobre todo, sigo siendo el hermano menos famoso.",
	"El desierto es tuyo. Y el talismán también, pero ese jármelo devuelves.",
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
@onready var sonido_exito: AudioStreamPlayer = $SonidoExito


func _ready() -> void:
	indicador.visible = false
	bocadillo.visible = false
	TemaUI.vistir_indicador(indicador, TemaUI.NARANJA)
	TemaUI.vistir_bocadillo(bocadillo, TemaUI.NARANJA)
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_tiempo += delta
	visual.scale.y = 1.0 + sin(_tiempo * 2.3) * 0.025


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
		indicador.visible = false
		GameState.dialogo_abierto = true
		sonido_hablar.play()
		return

	_indice_frase += 1
	if _indice_frase < _frases_actuales.size():
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		sonido_hablar.play()
	else:
		bocadillo.visible = false
		indicador.visible = true
		GameState.dialogo_abierto = false
		_cerrar_dialogo()


func _elegir_guion() -> Dictionary:
	if not GameState.hablo_con_ali:
		return {"frases": DIALOGO_INICIAL, "tipo": "inicial"}
	if not GameState.grito_aprendido:
		return {"frases": DIALOGO_SIN_GRITO, "tipo": "sin_grito"}
	if not GameState.cueva_abierta:
		return {"frases": DIALOGO_CERRADA, "tipo": "cerrada"}
	if GameState.tesoro_recogido and not GameState.talisman_obtenido:
		return {"frases": DIALOGO_TESORO, "tipo": "tesoro"}
	if (GameState.talisman_obtenido or GameState.mision_ali_completada) and not GameState.sellos_completados:
		if GameState.sellos_recogidos >= 3:
			return {"frases": DIALOGO_SELLOS_BIEN, "tipo": "sellos_bien"}
		if GameState.sellos_recogidos > 0:
			return {"frases": DIALOGO_SELLOS_FALTAN, "tipo": "sellos_faltan"}
		return {"frases": DIALOGO_SELLOS_PIDE, "tipo": "sellos_pide"}
	if GameState.sellos_completados:
		return {"frases": DIALOGO_FINAL, "tipo": "final"}
	return {"frases": DIALOGO_ABIERTA, "tipo": "abierta"}


func _cerrar_dialogo() -> void:
	match _tipo_dialogo:
		"inicial":
			GameState.registrar_charla_ali()
		"tesoro":
			GameState.completar_mision_ali()
			_celebrar()
		"sellos_bien":
			GameState.completar_sellos()
			_celebrar()


func _celebrar() -> void:
	sonido_exito.play()
	var centro := global_position + Vector2(0, -56)
	Efectos.anillo(centro, Color(1, 0.86, 0.35), 170.0, 7.0, 0.9)
	Efectos.destello(centro, Color(1, 0.95, 0.6), 52.0)
	Efectos.chispas(centro, Color(1, 0.85, 0.3), 26, 140.0, 0.9)


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
