extends CanvasLayer

const CATALOGO := [
	{
		"categoria": "sombrero",
		"titulo": "Sombrero",
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
		"items": [
			{"id": "sol", "nombre": "Sol"},
			{"id": "estrella", "nombre": "Estrella"},
		],
	},
	{
		"categoria": "guantes",
		"titulo": "Guantes",
		"items": [
			{"id": "blancos", "nombre": "Blancos"},
		],
	},
	{
		"categoria": "corbata",
		"titulo": "Corbata",
		"items": [
			{"id": "corbata", "nombre": "Elegante"},
		],
	},
	{
		"categoria": "camisa",
		"titulo": "Camisa",
		"items": [
			{"id": "rayas", "nombre": "A rayas"},
		],
	},
]

var _botones: Array[Dictionary] = []

@onready var contenedor: Control = $Contenedor
@onready var lista_categorias: VBoxContainer = $Contenedor/Panel/ListaCategorias


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	contenedor.visible = false
	_construir_menu()
	GameState.vestuario_cambiado.connect(_actualizar_botones)
	_actualizar_botones()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_C or event.keycode == KEY_TAB:
			_alternar_armario()
			get_viewport().set_input_as_handled()


func _alternar_armario() -> void:
	contenedor.visible = not contenedor.visible
	get_tree().paused = contenedor.visible
	if contenedor.visible:
		_actualizar_botones()


func _construir_menu() -> void:
	for cat_info in CATALOGO:
		var fila := HBoxContainer.new()
		fila.add_theme_constant_override("separation", 10)
		lista_categorias.add_child(fila)

		var etiqueta := Label.new()
		etiqueta.text = cat_info["titulo"] + ":"
		etiqueta.custom_minimum_size = Vector2(105, 34)
		etiqueta.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		etiqueta.add_theme_color_override("font_color", Color(0.113725, 0.117647, 0.14902, 1))
		etiqueta.add_theme_font_size_override("font_size", 15)
		fila.add_child(etiqueta)

		var cat: String = cat_info["categoria"]
		for item in cat_info["items"]:
			var boton := Button.new()
			boton.custom_minimum_size = Vector2(110, 34)
			boton.focus_mode = Control.FOCUS_NONE
			var item_id: String = item["id"]
			var item_nombre: String = item["nombre"]
			boton.pressed.connect(func() -> void: GameState.equipar_accesorio(cat, item_id))
			fila.add_child(boton)
			_botones.append({
				"boton": boton,
				"categoria": cat,
				"id": item_id,
				"nombre": item_nombre,
			})

		var btn_quitar := Button.new()
		btn_quitar.text = "Quitar"
		btn_quitar.custom_minimum_size = Vector2(82, 34)
		btn_quitar.focus_mode = Control.FOCUS_NONE
		btn_quitar.pressed.connect(func() -> void:
			if not GameState.obtener_equipado(cat).is_empty():
				GameState.equipar_accesorio(cat, GameState.obtener_equipado(cat))
		)
		fila.add_child(btn_quitar)


func _actualizar_botones() -> void:
	for info in _botones:
		var boton: Button = info["boton"]
		var cat: String = info["categoria"]
		var item_id: String = info["id"]
		var nombre: String = info["nombre"]

		var desbloqueado := GameState.esta_desbloqueado(cat, item_id)
		var equipado := GameState.obtener_equipado(cat) == item_id

		boton.disabled = not desbloqueado
		if not desbloqueado:
			boton.text = "???"
			boton.modulate = Color(0.65, 0.65, 0.7, 1.0)
		elif equipado:
			boton.text = "[OK] " + nombre
			boton.modulate = Color.WHITE
		else:
			boton.text = nombre
			boton.modulate = Color.WHITE
