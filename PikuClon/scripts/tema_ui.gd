class_name TemaUI
extends RefCounted
## Tema y estilos compartidos por todos los menús del juego.
##
## Centraliza la paleta, los estilos de botón y el "vestido" de paneles para
## que HUD, mapa, armario, viaje y pausa se vean iguales y coloridos.

const CREMA := Color("fff8e9")
const CREMA_HONDA := Color("f3e6c8")
const TINTA := Color("22202b")
const ROJO := Color("e63946")
const AMARILLO := Color("ffd13f")
const TEAL := Color("2ec4b6")
const AZUL := Color("3e8de3")
const ROSA := Color("f15bb5")
const NARANJA := Color("ff9f1c")
const VERDE := Color("43c59e")

static var _tema: Theme


static func tema() -> Theme:
	if _tema == null:
		_tema = _crear_tema()
	return _tema


static func aplicar(control: Control) -> void:
	if control != null:
		control.theme = tema()


## Caja redondeada reutilizable (para estilos sueltos fuera del tema).
static func caja(
		fondo: Color,
		borde: Color,
		radio: int,
		grosor: int = 0,
		margen_h: int = 0,
		margen_v: int = 0
) -> StyleBoxFlat:
	return _caja(fondo, borde, radio, grosor, margen_h, margen_v)


static func _caja(
		fondo: Color,
		borde: Color,
		radio: int,
		grosor: int = 0,
		margen_h: int = 0,
		margen_v: int = 0
) -> StyleBoxFlat:
	var estilo := StyleBoxFlat.new()
	estilo.bg_color = fondo
	estilo.corner_radius_top_left = radio
	estilo.corner_radius_top_right = radio
	estilo.corner_radius_bottom_left = radio
	estilo.corner_radius_bottom_right = radio
	estilo.anti_aliasing = true
	if grosor > 0:
		estilo.border_width_left = grosor
		estilo.border_width_top = grosor
		estilo.border_width_right = grosor
		estilo.border_width_bottom = grosor
		estilo.border_color = borde
	if margen_h > 0 or margen_v > 0:
		estilo.content_margin_left = margen_h
		estilo.content_margin_right = margen_h
		estilo.content_margin_top = margen_v
		estilo.content_margin_bottom = margen_v
	return estilo


static func _crear_tema() -> Theme:
	var t := Theme.new()

	# Tipografía redondeada del juego (Baloo 2, licencia OFL).
	var fuente: Font = load("res://recursos/fuentes/Baloo2.ttf")
	if fuente != null:
		t.default_font = fuente
		t.default_font_size = 16

	# --- Botones: coloridos, con relieve y foco bien visible ---
	t.set_font_size("font_size", "Button", 17)
	t.set_color("font_color", "Button", Color.WHITE)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_focus_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color("9c9484"))
	t.set_color("font_outline_color", "Button", TINTA)
	t.set_constant("outline_size", "Button", 4)

	t.set_stylebox("normal", "Button", _caja(VERDE, Color("1f9a8f"), 12, 2, 12, 8))
	t.set_stylebox("hover", "Button", _caja(Color("45d9cb"), Color("1f9a8f"), 12, 2, 12, 8))
	t.set_stylebox("pressed", "Button", _caja(Color("1f9a8f"), Color("157f76"), 12, 2, 12, 8))
	t.set_stylebox("disabled", "Button", _caja(Color("dcd3c0"), Color("c3b9a3"), 12, 2, 12, 8))
	var foco := _caja(Color(1, 1, 1, 0.0), AMARILLO, 14, 4)
	foco.expand_margin_left = 3
	foco.expand_margin_top = 3
	foco.expand_margin_right = 3
	foco.expand_margin_bottom = 3
	t.set_stylebox("focus", "Button", foco)

	# --- Etiquetas ---
	t.set_font_size("font_size", "Label", 16)
	t.set_color("font_color", "Label", TINTA)

	# --- Paneles ---
	t.set_stylebox("panel", "Panel", _estilo_panel(TEAL))
	t.set_stylebox("panel", "PanelContainer", _estilo_panel(TEAL))
	return t


static func _estilo_panel(acento: Color) -> StyleBoxFlat:
	var estilo := _caja(CREMA, acento, 20, 5)
	estilo.shadow_color = Color(0.05, 0.05, 0.1, 0.45)
	estilo.shadow_size = 18
	estilo.shadow_offset = Vector2(0, 10)
	return estilo


## Sustituye el marco plano (ColorRect "Borde"/"Fondo") de un panel por un
## panel redondeado con sombra y banda de título de color.
static func vistir_panel(panel: Control, acento: Color) -> void:
	if panel == null:
		return
	for nombre in ["Borde", "Fondo"]:
		var viejo := panel.get_node_or_null(nombre)
		if viejo is CanvasItem:
			(viejo as CanvasItem).visible = false
	if panel.has_node("FondoEstilo"):
		return

	var fondo := Panel.new()
	fondo.name = "FondoEstilo"
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fondo.add_theme_stylebox_override("panel", _estilo_panel(acento))
	panel.add_child(fondo)
	panel.move_child(fondo, 0)

	var titulo := panel.get_node_or_null("Titulo")
	if titulo is Label:
		var banda := Panel.new()
		banda.name = "BandaTitulo"
		banda.mouse_filter = Control.MOUSE_FILTER_IGNORE
		banda.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		banda.offset_bottom = 50.0
		var estilo_banda := _caja(acento, acento, 20)
		estilo_banda.corner_radius_bottom_left = 0
		estilo_banda.corner_radius_bottom_right = 0
		banda.add_theme_stylebox_override("panel", estilo_banda)
		panel.add_child(banda)
		panel.move_child(banda, 1)

		var etiqueta := titulo as Label
		etiqueta.add_theme_color_override("font_color", Color.WHITE)
		etiqueta.add_theme_color_override("font_outline_color", TINTA)
		etiqueta.add_theme_constant_override("outline_size", 6)
		etiqueta.add_theme_font_size_override("font_size", 22)
		panel.move_child(etiqueta, panel.get_child_count() - 1)


## Globito de diálogo de los NPC: panel redondeado con borde de color.
static func vistir_bocadillo(panel: Control, acento: Color) -> void:
	if panel == null:
		return
	for nombre in ["Borde", "Fondo"]:
		var viejo := panel.get_node_or_null(nombre)
		if viejo is CanvasItem:
			(viejo as CanvasItem).visible = false
	if panel.has_node("FondoEstilo"):
		return

	var fondo := Panel.new()
	fondo.name = "FondoEstilo"
	fondo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fondo.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var estilo := _caja(Color("fffaf0"), acento, 14, 3)
	estilo.shadow_color = Color(0.05, 0.05, 0.1, 0.4)
	estilo.shadow_size = 8
	estilo.shadow_offset = Vector2(0, 4)
	fondo.add_theme_stylebox_override("panel", estilo)
	panel.add_child(fondo)
	panel.move_child(fondo, 0)


## Globito pequeño de interacción ([E] Hablar / [E] Viajar): pastilla de color
## redondeada con borde claro y sombra, en vez de la caja negra.
static func vistir_indicador(indicador: Control, acento: Color) -> void:
	if indicador == null:
		return
	var fondo := indicador.get_node_or_null("Fondo")
	if fondo is CanvasItem:
		(fondo as CanvasItem).visible = false

	# Un poco más de aire para que la pastilla respire.
	indicador.offset_left -= 16.0
	indicador.offset_right += 16.0
	indicador.offset_top -= 3.0
	indicador.offset_bottom += 3.0
	if indicador.has_node("FondoEstilo"):
		return

	var panel := Panel.new()
	panel.name = "FondoEstilo"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var estilo := _caja(acento, acento.lightened(0.45), 14, 2)
	estilo.shadow_color = Color(0.05, 0.05, 0.1, 0.35)
	estilo.shadow_size = 6
	estilo.shadow_offset = Vector2(0, 3)
	panel.add_theme_stylebox_override("panel", estilo)
	indicador.add_child(panel)
	indicador.move_child(panel, 0)

	var texto := indicador.get_node_or_null("Texto")
	if texto is Label:
		var etiqueta := texto as Label
		etiqueta.add_theme_color_override("font_color", Color.WHITE)
		etiqueta.add_theme_color_override("font_outline_color", TINTA)
		etiqueta.add_theme_constant_override("outline_size", 4)
		etiqueta.add_theme_font_size_override("font_size", 15)
		indicador.move_child(etiqueta, indicador.get_child_count() - 1)
