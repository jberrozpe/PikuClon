extends CanvasLayer
## Menú de pausa: se abre con Esc y permite continuar, reiniciar la escena o
## salir del juego. Se maneja con ratón o con teclado (flechas + Enter).

const COLOR_SALIR := Color("e63946")

var abierto := false

@onready var contenedor: Control = $Contenedor
@onready var panel: Control = $Contenedor/Panel
@onready var lista: VBoxContainer = $Contenedor/Panel/ListaBotones
@onready var controles: VBoxContainer = $Contenedor/Panel/Controles


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	contenedor.visible = false
	TemaUI.aplicar(contenedor)
	TemaUI.vistir_panel(panel, TemaUI.NARANJA)
	_construir_botones()
	_construir_controles()


func _unhandled_input(evento: InputEvent) -> void:
	if not (evento is InputEventKey and evento.pressed and not evento.echo):
		return
	if evento.keycode != KEY_ESCAPE:
		return
	if abierto:
		cerrar()
	elif not get_tree().paused:
		abrir()
	else:
		# Hay otro menú abierto (mapa, armario, viaje): que lo cierre él.
		return
	get_viewport().set_input_as_handled()


func abrir() -> void:
	if abierto:
		return
	abierto = true
	contenedor.visible = true
	get_tree().paused = true
	_foco_primer_boton()


func cerrar() -> void:
	abierto = false
	contenedor.visible = false
	get_tree().paused = false


func _construir_botones() -> void:
	var opciones := [
		{"texto": "Continuar", "accion": cerrar},
		{"texto": "Nueva partida", "accion": _nueva_partida},
		{"texto": "Reiniciar escena", "accion": _reiniciar_escena},
		{"texto": "Salir del juego", "accion": _salir_del_juego},
	]
	for opcion in opciones:
		var boton := Button.new()
		boton.text = opcion["texto"]
		boton.custom_minimum_size = Vector2(0, 52)
		boton.focus_mode = Control.FOCUS_ALL
		boton.pressed.connect(opcion["accion"])
		lista.add_child(boton)

		if opcion["texto"] == "Salir del juego":
			boton.add_theme_stylebox_override("normal", TemaUI.caja(COLOR_SALIR, Color("b52b36"), 12, 2, 12, 8))
			boton.add_theme_stylebox_override("hover", TemaUI.caja(Color("f0525f"), Color("b52b36"), 12, 2, 12, 8))
			boton.add_theme_stylebox_override("pressed", TemaUI.caja(Color("b52b36"), Color("8f1f29"), 12, 2, 12, 8))


func _construir_controles() -> void:
	var titulo := Label.new()
	titulo.text = "CONTROLES"
	titulo.add_theme_font_size_override("font_size", 15)
	titulo.add_theme_color_override("font_color", TemaUI.NARANJA)
	controles.add_child(titulo)

	var rejilla := GridContainer.new()
	rejilla.columns = 2
	rejilla.add_theme_constant_override("h_separation", 10)
	rejilla.add_theme_constant_override("v_separation", 5)
	controles.add_child(rejilla)

	var filas := [
		["A / D", "Moverse"],
		["ESPACIO", "Saltar (doble)"],
		["S", "Agacharse"],
		["E", "Hablar / usar"],
		["Q", "Grito"],
		["F", "Magia de hielo"],
		["T", "Talismán"],
		["M", "Mapa"],
		["C", "Armario"],
		["ESC", "Pausa"],
	]
	for fila in filas:
		var tecla := Label.new()
		tecla.text = fila[0]
		tecla.add_theme_font_size_override("font_size", 12)
		tecla.add_theme_color_override("font_color", TemaUI.TINTA)
		tecla.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		tecla.custom_minimum_size = Vector2(76, 0)
		rejilla.add_child(tecla)

		var accion := Label.new()
		accion.text = fila[1]
		accion.add_theme_font_size_override("font_size", 12)
		accion.add_theme_color_override("font_color", Color("6b5f54"))
		rejilla.add_child(accion)


func _foco_primer_boton() -> void:
	for hijo in lista.get_children():
		if hijo is Button and not hijo.disabled:
			hijo.grab_focus()
			return


func _nueva_partida() -> void:
	cerrar()
	GameState.borrar_guardado()
	GameState.reiniciar_estado()
	GameState.ir_a_escena("res://escenas/pueblo.tscn")


func _reiniciar_escena() -> void:
	cerrar()
	get_tree().reload_current_scene()


func _salir_del_juego() -> void:
	get_tree().quit()
