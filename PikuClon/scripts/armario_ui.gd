extends CanvasLayer
## Armario de accesorios. Navegable con ratón y con teclado
## (flechas para moverse, Enter/Espacio para equipar, Esc para cerrar).

const CATALOGO := [
	{
		"categoria": "sombrero",
		"titulo": "Sombrero",
		"color": Color("f15bb5"),
		"items": [
			{"id": "copa", "nombre": "Copa"},
			{"id": "helice", "nombre": "Hélice"},
			{"id": "corona", "nombre": "Corona"},
			{"id": "tiroles", "nombre": "Tirolés"},
			{"id": "bombin", "nombre": "Bombín"},
			{"id": "ninja", "nombre": "Ninja"},
		],
	},
	{
		"categoria": "gafas",
		"titulo": "Gafas",
		"color": Color("3e8de3"),
		"items": [
			{"id": "sol", "nombre": "Sol"},
			{"id": "estrella", "nombre": "Estrella"},
		],
	},
	{
		"categoria": "guantes",
		"titulo": "Guantes",
		"color": Color("43c59e"),
		"items": [
			{"id": "blancos", "nombre": "Blancos"},
		],
	},
	{
		"categoria": "corbata",
		"titulo": "Corbata",
		"color": Color("ff9f1c"),
		"items": [
			{"id": "corbata", "nombre": "Elegante"},
		],
	},
	{
		"categoria": "lampara",
		"titulo": "Objeto",
		"color": Color("f2c230"),
		"items": [
			{"id": "lampara", "nombre": "Lámpara"},
			{"id": "antorcha", "nombre": "Antorcha"},
		],
	},
	{
		"categoria": "camisa",
		"titulo": "Camisa",
		"color": Color("2ec4b6"),
		"items": [
			{"id": "rayas", "nombre": "A rayas"},
		],
	},
]

var _botones: Array[Dictionary] = []
var _boton_cerrar: Button

@onready var contenedor: Control = $Contenedor
@onready var panel: Control = $Contenedor/Panel
@onready var lista_categorias: VBoxContainer = $Contenedor/Panel/ListaCategorias


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	contenedor.visible = false
	TemaUI.aplicar(contenedor)
	TemaUI.vistir_panel(panel, TemaUI.ROSA)
	_construir_menu()
	_crear_boton_cerrar()
	GameState.vestuario_cambiado.connect(_actualizar_botones)
	_actualizar_botones()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C or event.keycode == KEY_TAB:
			_alternar_armario()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and contenedor.visible:
			_alternar_armario()
			get_viewport().set_input_as_handled()


func _alternar_armario() -> void:
	contenedor.visible = not contenedor.visible
	get_tree().paused = contenedor.visible
	if contenedor.visible:
		_actualizar_botones()
		_foco_primer_boton()


func _foco_primer_boton() -> void:
	for info in _botones:
		var boton: Button = info["boton"]
		if not boton.disabled:
			boton.grab_focus()
			return
	_boton_cerrar.grab_focus()


func _crear_boton_cerrar() -> void:
	_boton_cerrar = Button.new()
	_boton_cerrar.text = "Cerrar  [C / Esc]"
	_boton_cerrar.focus_mode = Control.FOCUS_ALL
	_boton_cerrar.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	_boton_cerrar.offset_left = -218.0
	_boton_cerrar.offset_top = -62.0
	_boton_cerrar.offset_right = -20.0
	_boton_cerrar.offset_bottom = -14.0
	_boton_cerrar.add_theme_font_size_override("font_size", 15)
	_boton_cerrar.pressed.connect(_alternar_armario)
	panel.add_child(_boton_cerrar)


func _construir_menu() -> void:
	for cat_info in CATALOGO:
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 6)
		lista_categorias.add_child(fila)

		var color: Color = cat_info["color"]

		var etiqueta := Label.new()
		etiqueta.text = cat_info["titulo"]
		etiqueta.custom_minimum_size = Vector2(100, 38)
		etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		etiqueta.add_theme_color_override("font_color", color)
		etiqueta.add_theme_color_override("font_outline_color", TemaUI.TINTA)
		etiqueta.add_theme_constant_override("outline_size", 5)
		etiqueta.add_theme_font_size_override("font_size", 16)
		fila.add_child(etiqueta)

		var cat: String = cat_info["categoria"]
		for item in cat_info["items"]:
			var boton := Button.new()
			boton.custom_minimum_size = Vector2(106, 38)
			boton.focus_mode = Control.FOCUS_ALL
			var item_id: String = item["id"]
			var item_nombre: String = item["nombre"]
			boton.pressed.connect(func() -> void: _equipar(cat, item_id))
			fila.add_child(boton)
			_botones.append({
				"boton": boton,
				"categoria": cat,
				"id": item_id,
				"nombre": item_nombre,
				"color": color,
			})

		var btn_quitar := Button.new()
		btn_quitar.text = "Quitar"
		btn_quitar.custom_minimum_size = Vector2(84, 38)
		btn_quitar.focus_mode = Control.FOCUS_ALL
		btn_quitar.add_theme_stylebox_override("normal", TemaUI.caja(TemaUI.CREMA_HONDA, Color("c3b9a3"), 12, 2, 10, 8))
		btn_quitar.add_theme_stylebox_override("hover", TemaUI.caja(Color("fff0d0"), Color("c3b9a3"), 12, 2, 10, 8))
		btn_quitar.add_theme_stylebox_override("pressed", TemaUI.caja(TemaUI.CREMA_HONDA, Color("a89f8a"), 12, 2, 10, 8))
		btn_quitar.add_theme_color_override("font_color", TemaUI.TINTA)
		btn_quitar.add_theme_color_override("font_hover_color", TemaUI.TINTA)
		btn_quitar.add_theme_color_override("font_pressed_color", TemaUI.TINTA)
		btn_quitar.pressed.connect(func() -> void:
			var equipado := GameState.obtener_equipado(cat)
			if not equipado.is_empty():
				GameState.equipar_accesorio(cat, equipado)
		)
		fila.add_child(btn_quitar)


func _equipar(categoria: String, item_id: String) -> void:
	GameState.equipar_accesorio(categoria, item_id)


func _actualizar_botones() -> void:
	for info in _botones:
		var boton: Button = info["boton"]
		var cat: String = info["categoria"]
		var item_id: String = info["id"]
		var nombre: String = info["nombre"]
		var color: Color = info["color"]

		var desbloqueado := GameState.esta_desbloqueado(cat, item_id)
		var equipado := GameState.obtener_equipado(cat) == item_id

		boton.disabled = not desbloqueado
		boton.focus_mode = Control.FOCUS_ALL if desbloqueado else Control.FOCUS_NONE
		if not desbloqueado:
			boton.text = "???"
			var tenue := color.darkened(0.45)
			boton.add_theme_stylebox_override("normal", TemaUI.caja(tenue, tenue.darkened(0.2), 12, 2, 10, 8))
			boton.add_theme_stylebox_override("hover", TemaUI.caja(tenue.lightened(0.08), tenue.darkened(0.2), 12, 2, 10, 8))
			boton.add_theme_stylebox_override("pressed", TemaUI.caja(tenue.darkened(0.1), tenue.darkened(0.3), 12, 2, 10, 8))
			boton.add_theme_stylebox_override("disabled", TemaUI.caja(tenue, tenue.darkened(0.2), 12, 2, 10, 8))
			boton.add_theme_color_override("font_disabled_color", Color(1, 1, 1, 0.85))
		elif equipado:
			boton.text = "OK · " + nombre
			boton.add_theme_stylebox_override("normal", TemaUI.caja(color, color.darkened(0.25), 12, 3, 10, 8))
			boton.add_theme_stylebox_override("hover", TemaUI.caja(color.lightened(0.12), color.darkened(0.25), 12, 3, 10, 8))
			boton.add_theme_stylebox_override("pressed", TemaUI.caja(color.darkened(0.15), color.darkened(0.35), 12, 3, 10, 8))
		else:
			boton.text = nombre
			_limpiar_estilos(boton)


func _limpiar_estilos(boton: Button) -> void:
	for estado in ["normal", "hover", "pressed", "disabled"]:
		boton.remove_theme_stylebox_override(estado)
