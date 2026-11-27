extends Node2D
## Globo de viaje: al acercarse el jugador, E abre el mapa de destinos.
##
## Los destinos se desbloquean completando la fase anterior y, una vez
## completados, quedan disponibles para siempre. Al elegir uno, el globo
## despega con el jugador dentro antes de cambiar de escena.

const DESTINOS := [
	{
		"nombre": "Zona de Pruebas",
		"escena": "res://escenas/nivel_prueba.tscn",
		"punto": "",
		"requisito": "",
		"pista": "siempre disponible",
	},
	{
		"nombre": "Casa de Don Quesito",
		"escena": "res://escenas/nivel_2.tscn",
		"punto": "PuntoDesdeNivel1",
		"requisito": "mision_completada",
		"pista": "consigue la Estrella del Pueblo",
	},
	{
		"nombre": "Montañas Austríacas",
		"escena": "res://escenas/nivel_austria.tscn",
		"punto": "",
		"requisito": "mision_quesito_completada",
		"pista": "ayuda a Don Quesito",
	},
	{
		"nombre": "Selva Negra Alemana",
		"escena": "res://escenas/nivel_selva_negra.tscn",
		"punto": "",
		"requisito": "vaca_completada",
		"pista": "ayuda a la vaca alpina",
	},
	{
		"nombre": "Campiña Inglesa",
		"escena": "res://escenas/nivel_inglaterra.tscn",
		"punto": "",
		"requisito": "enanito_completado",
		"pista": "ayuda al enanito del bosque",
	},
	{
		"nombre": "Japón y su Volcán",
		"escena": "res://escenas/nivel_japon.tscn",
		"punto": "",
		"requisito": "ingles_completado",
		"pista": "ayuda al caballero inglés",
	},
	{
		"nombre": "Tíbet Nevado",
		"escena": "res://escenas/nivel_tibet.tscn",
		"punto": "",
		"requisito": "mono_completado",
		"pista": "ayuda al mono termal",
	},
	{
		"nombre": "Desierto de Arabia",
		"escena": "res://escenas/nivel_arabia.tscn",
		"punto": "",
		"requisito": "leccion_grito_completada",
		"pista": "aprende el grito en el Tíbet",
	},
	{
		"nombre": "España (Jefe Final)",
		"escena": "res://escenas/nivel_espana_boss.tscn",
		"punto": "",
		"requisito": "mision_ali_completada",
		"pista": "consigue el talismán de Ali Babá",
	},
]

const COLORES_DESTINO := [
	Color("e63946"),
	Color("ff9f1c"),
	Color("43c59e"),
	Color("3e8de3"),
	Color("f15bb5"),
	Color("2ec4b6"),
	Color("a7d8ff"),
	Color("e8b04b"),
	Color("ffd13f"),
]

var _jugador_cerca: bool = false
var _tiempo: float = 0.0
var _viajando: bool = false

@onready var visual: Sprite2D = $Visual
@onready var zona: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var menu_capa: CanvasLayer = $MenuViaje
@onready var contenedor_menu: Control = $MenuViaje/Contenedor
@onready var panel: Control = $MenuViaje/Contenedor/Panel
@onready var lista_destinos: VBoxContainer = $MenuViaje/Contenedor/Panel/ListaDestinos
@onready var sonido_viaje: AudioStreamPlayer2D = $SonidoViaje
@onready var sonido_despegue: AudioStreamPlayer2D = $SonidoDespegue


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	indicador.visible = false
	TemaUI.vistir_indicador(indicador, TemaUI.NARANJA)
	contenedor_menu.visible = false
	menu_capa.process_mode = Node.PROCESS_MODE_ALWAYS
	TemaUI.aplicar(contenedor_menu)
	TemaUI.vistir_panel(panel, TemaUI.VERDE)
	if GameState.DESBLOQUEAR_TODO:
		var titulo := panel.get_node_or_null("Titulo")
		if titulo is Label:
			(titulo as Label).text = "GLOBO DE VIAJE  ·  MODO PRUEBAS"
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	if get_tree().paused or _viajando:
		return
	_tiempo += delta
	visual.position.y = -128.0 + sin(_tiempo * 2.2) * 4.0


func _unhandled_input(event: InputEvent) -> void:
	if _viajando:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and _jugador_cerca:
			_alternar_menu()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and contenedor_menu.visible:
			_cerrar_menu()
			get_viewport().set_input_as_handled()


func _alternar_menu() -> void:
	if contenedor_menu.visible:
		_cerrar_menu()
	else:
		# Se reconstruye cada vez para reflejar el progreso más reciente.
		_construir_destinos()
		contenedor_menu.visible = true
		indicador.visible = false
		get_tree().paused = true
		_foco_primer_boton()


func _cerrar_menu() -> void:
	contenedor_menu.visible = false
	get_tree().paused = false
	if _jugador_cerca and not _viajando:
		indicador.visible = true


func _foco_primer_boton() -> void:
	for hijo in lista_destinos.get_children():
		if hijo is Button and not hijo.disabled:
			hijo.grab_focus()
			return


func _desbloqueado(destino: Dictionary) -> bool:
	if GameState.DESBLOQUEAR_TODO:
		return true
	var clave: String = destino.get("requisito", "")
	if clave.is_empty():
		return true
	return bool(GameState.get(clave))


func _construir_destinos() -> void:
	for hijo in lista_destinos.get_children():
		lista_destinos.remove_child(hijo)
		hijo.queue_free()

	var indice := 0
	for dest in DESTINOS:
		var disponible := _desbloqueado(dest)
		var boton := Button.new()
		boton.custom_minimum_size = Vector2(560, 42)
		boton.focus_mode = Control.FOCUS_ALL if disponible else Control.FOCUS_NONE
		boton.disabled = not disponible
		boton.add_theme_font_size_override("font_size", 15)

		var color: Color = COLORES_DESTINO[indice % COLORES_DESTINO.size()]
		if disponible:
			boton.text = dest["nombre"]
			boton.add_theme_stylebox_override("normal", TemaUI.caja(color, color.darkened(0.25), 12, 2, 12, 8))
			boton.add_theme_stylebox_override("hover", TemaUI.caja(color.lightened(0.15), color.darkened(0.25), 12, 2, 12, 8))
			boton.add_theme_stylebox_override("pressed", TemaUI.caja(color.darkened(0.18), color.darkened(0.35), 12, 2, 12, 8))
			var ruta: String = dest["escena"]
			var punto: String = dest["punto"]
			boton.pressed.connect(func() -> void:
				if _desbloqueado(dest):
					_viajar(ruta, punto)
			)
		else:
			boton.text = "%s  ·  bloqueado: %s" % [dest["nombre"], dest["pista"]]
			boton.add_theme_stylebox_override("disabled",
					TemaUI.caja(Color("cfc7b6"), Color("b4ab98"), 12, 2, 12, 8))
			boton.add_theme_color_override("font_disabled_color", Color("6d665c"))

		lista_destinos.add_child(boton)
		indice += 1

	var btn_cerrar := Button.new()
	btn_cerrar.text = "Cerrar  [E / Esc]"
	btn_cerrar.custom_minimum_size = Vector2(560, 42)
	btn_cerrar.focus_mode = Control.FOCUS_ALL
	btn_cerrar.add_theme_stylebox_override("normal", TemaUI.caja(TemaUI.CREMA_HONDA, Color("c3b9a3"), 12, 2, 12, 8))
	btn_cerrar.add_theme_stylebox_override("hover", TemaUI.caja(Color("fff0d0"), Color("c3b9a3"), 12, 2, 12, 8))
	btn_cerrar.add_theme_stylebox_override("pressed", TemaUI.caja(TemaUI.CREMA_HONDA, Color("a89f8a"), 12, 2, 12, 8))
	btn_cerrar.add_theme_color_override("font_color", TemaUI.TINTA)
	btn_cerrar.add_theme_color_override("font_hover_color", TemaUI.TINTA)
	btn_cerrar.add_theme_color_override("font_pressed_color", TemaUI.TINTA)
	btn_cerrar.pressed.connect(_cerrar_menu)
	lista_destinos.add_child(btn_cerrar)


func _viajar(ruta: String, punto: String) -> void:
	if _viajando:
		return
	_viajando = true
	_cerrar_menu()
	indicador.visible = false
	get_tree().paused = false

	var jugador := get_tree().current_scene.find_child("Jugador", true, false)
	if jugador is CharacterBody2D:
		jugador.set_physics_process(false)
		jugador.velocity = Vector2.ZERO

	# 1) El jugador se sube a la cesta.
	if jugador is CharacterBody2D:
		var subir := create_tween()
		subir.tween_property(jugador, "global_position",
				global_position + Vector2(0, -28), 0.35).set_ease(Tween.EASE_OUT)
		await subir.finished

	# 2) El globo despega hacia arriba con el jugador a bordo.
	if sonido_despegue != null:
		sonido_despegue.play()
	var destino := global_position + Vector2(0, -1100)
	var despegue := create_tween()
	despegue.set_parallel(true)
	despegue.tween_property(self, "global_position", destino, 1.7) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	if jugador is CharacterBody2D:
		despegue.tween_property(jugador, "global_position", destino + Vector2(0, -28), 1.7) \
				.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	despegue.tween_property(visual, "rotation", 0.22, 1.0)
	despegue.tween_property(visual, "scale", Vector2(1.12, 1.12), 1.7)
	await despegue.finished

	GameState.ir_a_escena(ruta, punto)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = true
		if not contenedor_menu.visible and not _viajando:
			indicador.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = false
		indicador.visible = false
