extends CanvasLayer
## Mandos táctiles: dibuja botones y gestiona varios dedos a la vez.

const ACCIONES := {
	"izquierda": "mover_izquierda",
	"derecha": "mover_derecha",
	"saltar": "saltar",
	"patada": "patada",
	"bola": "agacharse",
}
const TECLAS := {
	"hablar": KEY_E,
	"armario": KEY_C,
	"mapa": KEY_M,
	"menu": KEY_ESCAPE,
}

var _activo: bool = false
var _botones: Array[Dictionary] = []
var _dedos: Dictionary = {}
var _pad: Control


func _ready() -> void:
	layer = 60
	_asegurar_acciones()
	_activo = DisplayServer.is_touchscreen_available() or OS.get_environment("PIKU_TOUCH") == "1"
	visible = _activo
	if not _activo:
		return
	_crear_pad()


func _asegurar_acciones() -> void:
	for accion in ACCIONES.values():
		if not InputMap.has_action(accion):
			InputMap.add_action(accion)


func _crear_pad() -> void:
	var tam := get_viewport().get_visible_rect().size
	# botones: nombre, texto, centro, radio, accion o tecla
	_registrar("izquierda", "◀", Vector2(70, tam.y - 95), 40, ACCIONES["izquierda"], "")
	_registrar("derecha", "▶", Vector2(160, tam.y - 95), 40, ACCIONES["derecha"], "")
	_registrar("saltar", "SALTO", Vector2(tam.x - 85, tam.y - 130), 48, ACCIONES["saltar"], "")
	_registrar("patada", "PATADA", Vector2(tam.x - 190, tam.y - 110), 42, ACCIONES["patada"], "")
	_registrar("bola", "BOLA", Vector2(tam.x - 85, tam.y - 55), 34, ACCIONES["bola"], "")
	_registrar("hablar", "E", Vector2(46, 142), 24, "", "hablar")
	_registrar("armario", "C", Vector2(98, 142), 24, "", "armario")
	_registrar("mapa", "M", Vector2(150, 142), 24, "", "mapa")
	_registrar("menu", "☰", Vector2(202, 142), 24, "", "menu")

	_pad = Control.new()
	_pad.name = "Pad"
	_pad.set_anchors_preset(Control.PRESET_FULL_RECT)
	_pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pad.draw.connect(_dibujar)
	add_child(_pad)


func _registrar(nombre: String, texto: String, centro: Vector2, radio: float,
		accion: String, tecla: String) -> void:
	_botones.append({
		"nombre": nombre, "texto": texto, "centro": centro,
		"radio": radio, "accion": accion, "tecla": tecla, "pulsado": false,
	})


func _input(event: InputEvent) -> void:
	if not _activo:
		return
	if event is InputEventScreenTouch:
		if event.pressed:
			_tocar(event.index, event.position)
		else:
			_soltar(event.index)
	elif event is InputEventScreenDrag:
		# si el dedo se desliza, se reevalúa
		_soltar(event.index)
		_tocar(event.index, event.position)


func _tocar(indice: int, pos: Vector2) -> void:
	print("TOCAR ", indice, " en ", pos, " botones ", _botones.size())
	for b in _botones:
		if pos.distance_to(b["centro"]) <= b["radio"]:
			_dedos[indice] = b["nombre"]
			if b["accion"] != "":
				Input.action_press(b["accion"])
				b["pulsado"] = true
			else:
				_pulsar_tecla(b["tecla"])
			_pad.queue_redraw()
			return


func _soltar(indice: int) -> void:
	if not _dedos.has(indice):
		return
	var nombre: String = _dedos[indice]
	_dedos.erase(indice)
	for b in _botones:
		if b["nombre"] == nombre:
			if b["accion"] != "":
				Input.action_release(b["accion"])
			b["pulsado"] = false
	_pad.queue_redraw()


func _dibujar() -> void:
	var fuente := ThemeDB.fallback_font
	for b in _botones:
		var centro: Vector2 = b["centro"]
		var radio: float = b["radio"]
		var pulsado: bool = b["pulsado"]
		_pad.draw_circle(centro, radio, Color(0.08, 0.08, 0.1, 0.5 if pulsado else 0.2))
		_pad.draw_arc(centro, radio, 0.0, TAU, 48, Color(1, 1, 1, 0.32), 2.0, true)
		var texto: String = b["texto"]
		var tam_fuente := 15 if radio >= 45 else 12
		var ancho := fuente.get_string_size(texto, HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente).x
		_pad.draw_string(fuente, centro + Vector2(-ancho * 0.5, tam_fuente * 0.35), texto,
				HORIZONTAL_ALIGNMENT_LEFT, -1, tam_fuente, Color(1, 1, 1, 0.72))


func _pulsar_tecla(nombre: String) -> void:
	var codigo: int = TECLAS[nombre]
	var evento := InputEventKey.new()
	evento.keycode = codigo
	evento.physical_keycode = codigo
	evento.pressed = true
	Input.parse_input_event(evento)
	await get_tree().create_timer(0.05).timeout
	var soltar := InputEventKey.new()
	soltar.keycode = codigo
	soltar.physical_keycode = codigo
	soltar.pressed = false
	Input.parse_input_event(soltar)
