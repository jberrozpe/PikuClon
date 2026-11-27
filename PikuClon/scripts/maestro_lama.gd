extends Node2D
## Maestro tibetano: enseña el Grito Gutural y la Magia del Hielo.
##   Lección 1: romper 3 rocas sagradas con el grito.
##   Lección 2: congelar 3 yetis con la magia del hielo.

const DIALOGO_INICIAL: Array[String] = [
	"Bienvenido a las montañas donde el viento susurra... y a veces grita.",
	"Soy el Lama Tranquilo. Llevo 30 años meditando para no gritar. Y hoy vas a aprender a gritar.",
	"Lección 1: el Grito Gutural. Rompe 3 rocas sagradas con él (tecla Q).",
	"Respira hondo, piensa en algo que te enfade... como que se acabe el onigiri.",
]

const DIALOGO_ROCAS: Array[String] = [
	"Las rocas sagradas siguen enteras. ¡GRITA! (Q).",
	"Consejo de lama: frunce el ceño y grita desde la barriga, no desde la garganta.",
]

const DIALOGO_APRENDE_GRITO: Array[String] = [
	"¡KIAUUU...! Perdón, se me escapó. ¡Ese grito ha despertado a la montaña entera!",
	"Tu grito rompe piedra y metal: úsalo para abrir puertas selladas.",
	"Ahora la Lección 2: la Magia del Hielo. Congela a los 3 yetis del valle (tecla F).",
	"Sin daño, ¿eh? Solo un ratito de frío para que reflexionen.",
]

const DIALOGO_YETIS: Array[String] = [
	"Los yetis siguen calentitos. Congélalos con F.",
	"Si te persiguen, recuerda: el hielo también sirve para enfriar los ánimos.",
]

const DIALOGO_APRENDE_HIELO: Array[String] = [
	"¡Perfecto! Nieve, hielo y un grito que rompe montañas. Ya eres oficialmente un maestro.",
	"Bueno, oficialmente eres mi alumno favorito. Que tampoco es difícil: solo tengo uno.",
	"Ve al desierto cuando quieras: Ali Babá lleva años esperando a alguien con tu voz.",
]

const DIALOGO_FINAL: Array[String] = [
	"La montaña está en calma. Tú, no tanto.",
	"Medita, respira... y si algo se rompe, ya sabes de quién es la culpa.",
]

var _jugador_cerca: bool = false
var _escala_base: Vector2 = Vector2.ONE
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
	TemaUI.vistir_indicador(indicador, TemaUI.AMARILLO)
	TemaUI.vistir_bocadillo(bocadillo, TemaUI.AMARILLO)
	_escala_base = visual.scale
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_tiempo += delta
	visual.scale.y = _escala_base.y * (1.0 + sin(_tiempo * 2.0) * 0.03)
	visual.rotation = sin(_tiempo * 0.9) * 0.015


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
	if not GameState.hablo_con_lama:
		return {"frases": DIALOGO_INICIAL, "tipo": "inicial"}

	if not GameState.leccion_grito_completada:
		if GameState.rocas_rotas >= GameState.ROCAS_MISION:
			return {"frases": DIALOGO_APRENDE_GRITO, "tipo": "aprender_grito"}
		return {"frases": DIALOGO_ROCAS, "tipo": "rocas"}

	if not GameState.leccion_hielo_completada:
		if GameState.yetis_congelados >= GameState.YETIS_MISION:
			return {"frases": DIALOGO_APRENDE_HIELO, "tipo": "aprender_hielo"}
		return {"frases": DIALOGO_YETIS, "tipo": "yetis"}

	return {"frases": DIALOGO_FINAL, "tipo": "final"}


func _cerrar_dialogo() -> void:
	match _tipo_dialogo:
		"inicial":
			GameState.registrar_charla_lama()
			GameState.aprender_grito()
		"aprender_grito":
			GameState.completar_leccion_grito()
			GameState.aprender_hielo()
			_celebrar(Color(0.95, 0.82, 0.4))
		"aprender_hielo":
			GameState.completar_leccion_hielo()
			_celebrar(Color(0.6, 0.9, 1.0))


func _celebrar(color: Color) -> void:
	sonido_exito.play()
	var centro := global_position + Vector2(0, -52)
	Efectos.anillo(centro, color, 160.0, 6.0, 0.8)
	Efectos.destello(centro, Color(1, 1, 1, 0.95), 48.0)
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
