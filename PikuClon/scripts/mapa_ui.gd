extends CanvasLayer

@onready var contenedor: Control = $Contenedor
@onready var marcador_jugador: Polygon2D = $Contenedor/Panel/MapaZona/MarcadorJugador
@onready var etiqueta_zona: Label = $Contenedor/Panel/Pie/EtiquetaZona
@onready var etiqueta_misiones: Label = $Contenedor/Panel/Pie/EtiquetaMisiones
@onready var zonas_contenedor: Node2D = $Contenedor/Panel/MapaZona/Zonas


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	contenedor.visible = false
	GameState.mision_actualizada.connect(_actualizar_mapa)
	_actualizar_mapa()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		_alternar_mapa()


func _alternar_mapa() -> void:
	contenedor.visible = not contenedor.visible
	get_tree().paused = contenedor.visible
	if contenedor.visible:
		_actualizar_mapa()


func _actualizar_mapa() -> void:
	etiqueta_zona.text = "Ubicación actual: " + GameState.zona_actual

	var estado_estrella := "Completada" if GameState.mision_completada else ("Estrella recogida" if GameState.estrella_recogida else "Pendiente")
	var estado_rayo := "Completada" if GameState.mision_quesito_completada else ("Rayo en caja" if GameState.rayo_en_caja else "Pendiente")
	etiqueta_misiones.text = "Misión Estrella: %s  |  Misión Rayo: %s" % [estado_estrella, estado_rayo]

	var nodo_zona := zonas_contenedor.get_node_or_null(GameState.zona_actual)
	if nodo_zona is Node2D:
		marcador_jugador.position = (nodo_zona as Node2D).position + Vector2(0.0, -24.0)
		marcador_jugador.visible = true
	else:
		var pueblo := zonas_contenedor.get_node_or_null("Pueblo")
		if pueblo is Node2D:
			marcador_jugador.position = (pueblo as Node2D).position + Vector2(0.0, -24.0)
