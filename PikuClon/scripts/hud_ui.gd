extends CanvasLayer

@onready var contenedor: Control = $Contenedor
@onready var caja_piezas: Control = $Contenedor/CajaPiezas
@onready var caja_atajos: Control = $Contenedor/CajaAtajos
@onready var etiqueta_piezas: Label = $Contenedor/CajaPiezas/EtiquetaPiezas
@onready var etiqueta_atajos: Label = $Contenedor/CajaAtajos/Texto

var _caja_leccion: Control
var _etiqueta_leccion: Label


var aviso_guardado: Label


func _ready() -> void:
	TemaUI.aplicar(contenedor)
	TemaUI.vistir_panel(caja_piezas, TemaUI.AMARILLO)
	TemaUI.vistir_panel(caja_atajos, TemaUI.ROSA)
	caja_atajos.offset_left = -560.0
	etiqueta_atajos.add_theme_font_size_override("font_size", 13)
	etiqueta_atajos.add_theme_color_override("font_color", Color.WHITE)
	etiqueta_atajos.add_theme_color_override("font_outline_color", TemaUI.TINTA)
	etiqueta_atajos.add_theme_constant_override("outline_size", 4)
	etiqueta_piezas.add_theme_color_override("font_color", TemaUI.TINTA)
	etiqueta_piezas.add_theme_font_size_override("font_size", 16)
	_crear_caja_leccion()
	_crear_aviso_guardado()
	GameState.mision_actualizada.connect(_actualizar_hud)
	GameState.partida_guardada.connect(_avisar_guardado)
	GameState.vidas_cambiadas.connect(_actualizar_vidas)
	_crear_vidas()
	_actualizar_hud()


func _crear_caja_leccion() -> void:
	_caja_leccion = Control.new()
	_caja_leccion.name = "CajaLeccion"
	_caja_leccion.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	_caja_leccion.offset_left = -190.0
	_caja_leccion.offset_right = 190.0
	_caja_leccion.offset_top = 14.0
	_caja_leccion.offset_bottom = 50.0
	contenedor.add_child(_caja_leccion)

	_etiqueta_leccion = Label.new()
	_etiqueta_leccion.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_etiqueta_leccion.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_etiqueta_leccion.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_etiqueta_leccion.add_theme_font_size_override("font_size", 15)
	_etiqueta_leccion.add_theme_color_override("font_color", TemaUI.TINTA)
	_etiqueta_leccion.add_theme_color_override("font_outline_color", Color.WHITE)
	_etiqueta_leccion.add_theme_constant_override("outline_size", 3)
	_caja_leccion.add_child(_etiqueta_leccion)

	TemaUI.vistir_panel(_caja_leccion, TemaUI.NARANJA)


var etiqueta_vidas: Label


func _crear_vidas() -> void:
	etiqueta_vidas = Label.new()
	etiqueta_vidas.add_theme_font_size_override("font_size", 20)
	etiqueta_vidas.add_theme_color_override("font_color", Color("e8434a"))
	etiqueta_vidas.add_theme_color_override("font_outline_color", TemaUI.TINTA)
	etiqueta_vidas.add_theme_constant_override("outline_size", 5)
	etiqueta_vidas.position = Vector2(24, 58)
	contenedor.add_child(etiqueta_vidas)
	_actualizar_vidas()


func _actualizar_vidas() -> void:
	if etiqueta_vidas == null:
		return
	var corazones := ""
	for i in range(max(GameState.vidas, 0)):
		corazones += "♥ "
	etiqueta_vidas.text = corazones.strip_edges()


func _crear_aviso_guardado() -> void:
	aviso_guardado = Label.new()
	aviso_guardado.text = "PARTIDA GUARDADA"
	aviso_guardado.add_theme_font_size_override("font_size", 14)
	aviso_guardado.add_theme_color_override("font_color", Color.WHITE)
	aviso_guardado.add_theme_color_override("font_outline_color", TemaUI.TINTA)
	aviso_guardado.add_theme_constant_override("outline_size", 4)
	aviso_guardado.modulate.a = 0.0
	aviso_guardado.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	aviso_guardado.offset_top = -96.0
	aviso_guardado.offset_bottom = -70.0
	aviso_guardado.offset_left = -120.0
	aviso_guardado.offset_right = 120.0
	aviso_guardado.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	contenedor.add_child(aviso_guardado)


func _avisar_guardado() -> void:
	if aviso_guardado == null:
		return
	aviso_guardado.modulate.a = 1.0
	var tween := create_tween()
	tween.tween_interval(0.6)
	tween.tween_property(aviso_guardado, "modulate:a", 0.0, 0.6)


func _actualizar_hud() -> void:
	etiqueta_piezas.text = "Piezas Brillantes: %d/%d" % [GameState.piezas_brillantes, GameState.TOTAL_PIEZAS]
	_actualizar_atajos()
	_actualizar_leccion()


func _actualizar_atajos() -> void:
	var partes := ["[M] Mapa", "[C] Armario"]
	if GameState.grito_aprendido:
		partes.append("[Q] Grito")
	if GameState.hielo_aprendido:
		partes.append("[F] Hielo")
	if GameState.talisman_obtenido:
		partes.append("[T] Escudo")
	partes.append("[Esc] Menú")
	etiqueta_atajos.text = "  ·  ".join(partes)


func _actualizar_leccion() -> void:
	if GameState.hablo_con_lama and not GameState.leccion_grito_completada:
		_mostrar_leccion("Lección: rompe rocas  %d/%d" % [
			GameState.rocas_rotas, GameState.ROCAS_MISION])
		return
	if GameState.hablo_con_lama and not GameState.leccion_hielo_completada:
		_mostrar_leccion("Lección: congela yetis  %d/%d" % [
			GameState.yetis_congelados, GameState.YETIS_MISION])
		return
	if GameState.hablo_con_ali and not GameState.mision_ali_completada:
		if not GameState.cueva_abierta:
			_mostrar_leccion("Ali Babá: abre la cueva con el grito")
		elif not GameState.tesoro_recogido:
			_mostrar_leccion("Ali Babá: busca el tesoro en la cueva")
		else:
			_mostrar_leccion("Lleva el tesoro a Ali Babá")
		return
	if GameState.hablo_con_maestro and not GameState.leccion_doble_salto_completada:
		_mostrar_leccion("Lección: rompe tablones  %d/%d" % [
			GameState.tablones_rotos, GameState.TABLONES_MISION])
		return
	if GameState.hablo_con_maestro and not GameState.leccion_patada_completada:
		_mostrar_leccion("Lección: dianas aéreas  %d/%d" % [
			GameState.dianas_golpeadas, GameState.DIANAS_MISION])
		return
	_caja_leccion.visible = false


func _mostrar_leccion(texto: String) -> void:
	_caja_leccion.visible = true
	_etiqueta_leccion.text = texto


