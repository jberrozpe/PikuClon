extends Node2D
## Dueño de la vaca. Cuenta historias extravagantes de su día a día.

const HISTORIAS: Array = [
	["La vaca se llama Brunilda. O eso creo, porque ya van tres Brunildas.",
	 "La anterior se mudó a otra ladera sin avisar. Se llevó mi cubo y mi dignidad."],
	["Ayer la vaca aprendió a abrir la puerta del establo.",
	 "No me molesta que la abra. Me molesta que la cierre con llave por fuera."],
	["Ordeñar a las cinco de la mañana no está mal.",
	 "Lo malo es que la vaca también madruga, y opina. Opina muchísimo."],
	["Una vez se subió al tejado para ver el amanecer.",
	 "Bajó por la chimenea. Con estilo, eso sí. Y con hollín en la leche."],
	["Yo quería un perro. Mi mujer quería una vaca.",
	 "Ahora tenemos una vaca que ladra. No pregunten. Solo no pregunten."],
	["La vaca y yo tenemos un trato: yo la ordeño, ella no me juzga.",
	 "Va fatal. Ella juzga. Juzga sobre todo cuando llego tarde."],
	["El otro día la encontré leyendo el periódico.",
	 "Solo lee la sección de pastos y el horóscopo. Dice que es Tauro. Claro."],
	["Vendo leche, queso y rumores.",
	 "Los rumores se venden mejor. Sobre todo los de la vaca de la ladera de enfrente."],
	["Anoche la vaca se comió mi sombrero nuevo.",
	 "Luego me miró como diciendo: 'tampoco era para tanto'. Y tenía razón."],
]

var _jugador_cerca: bool = false
var _tiempo: float = 0.0
var _historia: int = 0
var _frases_actuales: Array = []
var _indice_frase: int = 0

@onready var visual: Node2D = get_node_or_null("Visual")
@onready var zona: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var bocadillo: Control = $Bocadillo
@onready var texto_bocadillo: Label = $Bocadillo/Texto
@onready var sonido_hablar: AudioStreamPlayer2D = $SonidoHablar

var _escala_base: Vector2 = Vector2.ONE


func _ready() -> void:
	if visual != null:
		_escala_base = visual.scale
	indicador.visible = false
	bocadillo.visible = false
	TemaUI.vistir_indicador(indicador, TemaUI.VERDE)
	TemaUI.vistir_bocadillo(bocadillo, TemaUI.VERDE)
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_tiempo += delta
	if visual != null:
		visual.scale.y = _escala_base.y * (1.0 + sin(_tiempo * 2.2) * 0.03)
		visual.rotation = sin(_tiempo * 1.1) * 0.012


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if GameState.dialogo_abierto and not bocadillo.visible:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar_dialogo()


func _avanzar_dialogo() -> void:
	if not bocadillo.visible:
		_frases_actuales = HISTORIAS[_historia % HISTORIAS.size()]
		_historia += 1
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
