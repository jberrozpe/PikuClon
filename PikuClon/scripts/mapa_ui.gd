extends CanvasLayer
## Mapa del mundo. Se abre con M, se cierra con M, Esc o el botón "Cerrar".

@onready var contenedor: Control = $Contenedor
@onready var panel: Control = $Contenedor/Panel
@onready var marcador_jugador: Polygon2D = $Contenedor/Panel/MapaZona/MarcadorJugador
@onready var etiqueta_zona: Label = $Contenedor/Panel/Pie/EtiquetaZona
@onready var etiqueta_misiones: Label = $Contenedor/Panel/Pie/EtiquetaMisiones
@onready var zonas_contenedor: Node2D = $Contenedor/Panel/MapaZona/Zonas

var _boton_cerrar: Button
var _pulso: float = 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	contenedor.visible = false
	TemaUI.aplicar(contenedor)
	TemaUI.vistir_panel(panel, TemaUI.AZUL)
	_crear_boton_cerrar()
	_decorar_zonas()
	GameState.mision_actualizada.connect(_actualizar_mapa)
	_actualizar_mapa()


func _process(delta: float) -> void:
	if not contenedor.visible:
		return
	# Latido del marcador del jugador.
	_pulso += delta * 4.0
	marcador_jugador.scale = Vector2.ONE * (1.0 + sin(_pulso) * 0.12)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	if event.keycode == KEY_M:
		_alternar_mapa()
		get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and contenedor.visible:
		_alternar_mapa()
		get_viewport().set_input_as_handled()


func _alternar_mapa() -> void:
	contenedor.visible = not contenedor.visible
	get_tree().paused = contenedor.visible
	if contenedor.visible:
		_actualizar_mapa()
		_boton_cerrar.grab_focus()


func _crear_boton_cerrar() -> void:
	_boton_cerrar = Button.new()
	_boton_cerrar.text = "Cerrar  [M / Esc]"
	_boton_cerrar.focus_mode = Control.FOCUS_ALL
	_boton_cerrar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_boton_cerrar.offset_left = -196.0
	_boton_cerrar.offset_top = -58.0
	_boton_cerrar.offset_right = -18.0
	_boton_cerrar.offset_bottom = -12.0
	_boton_cerrar.add_theme_font_size_override("font_size", 15)
	_boton_cerrar.pressed.connect(_alternar_mapa)
	panel.add_child(_boton_cerrar)


## Añade un aro blanco a cada punto del mapa para que se lea mejor.
func _decorar_zonas() -> void:
	for zona in zonas_contenedor.get_children():
		var punto := zona.get_node_or_null("Punto")
		if not (punto is Polygon2D):
			continue
		var aro := Line2D.new()
		aro.name = "Aro"
		aro.width = 2.5
		aro.default_color = Color(1, 1, 1, 0.9)
		aro.closed = true
		var radio := 15.0
		for i in range(16):
			var angulo := TAU * i / 16.0
			aro.add_point(Vector2(cos(angulo), sin(angulo)) * radio)
		zona.add_child(aro)


func _actualizar_mapa() -> void:
	etiqueta_zona.text = "Ubicación actual: " + GameState.zona_actual

	var estado_estrella := "Completada" if GameState.mision_completada else ("Estrella recogida" if GameState.estrella_recogida else "Pendiente")
	var estado_rayo := "Completada" if GameState.mision_quesito_completada else ("Rayo en caja" if GameState.rayo_en_caja else "Pendiente")
	etiqueta_misiones.text = "Misión Estrella: %s  |  Misión Rayo: %s" % [estado_estrella, estado_rayo]

	var nodo_zona := zonas_contenedor.get_node_or_null(GameState.zona_actual)
	if nodo_zona is Node2D:
		marcador_jugador.position = (nodo_zona as Node2D).position + Vector2(0.0, -26.0)
		marcador_jugador.visible = true
	else:
		var pueblo := zonas_contenedor.get_node_or_null("Pueblo")
		if pueblo is Node2D:
			marcador_jugador.position = (pueblo as Node2D).position + Vector2(0.0, -26.0)
