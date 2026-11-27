extends Node

signal mision_actualizada
signal vestuario_cambiado
signal vidas_cambiadas
signal partida_guardada

const TOTAL_PIEZAS: int = 4
const TABLONES_MISION: int = 3
const DIANAS_MISION: int = 3
const ROCAS_MISION: int = 3
const YETIS_MISION: int = 3

## MODO PRUEBAS: con true, todos los destinos del globo están disponibles y la
## cueva de Ali Babá nace abierta. Ponlo en false para la versión final.
const DESBLOQUEAR_TODO: bool = false

var piezas_brillantes: int = 0
var hablo_con_alcalde: bool = false
var carta_tejados_recogida: bool = false
var vecino1_completado: bool = false
var vecino2_completado: bool = false
var hablo_con_npc: bool = false
var estrella_recogida: bool = false
var mision_completada: bool = false
var hablo_con_quesito: bool = false
var rayo_en_caja: bool = false
var mision_quesito_completada: bool = false
var pieza_austria_recogida: bool = false
var hablo_con_vaca: bool = false
var flor_vaca_recogida: bool = false
var vaca_completada: bool = false
var pieza_selva_recogida: bool = false
var hablo_con_enanito: bool = false
var bellota_recogida: bool = false
var enanito_completado: bool = false
var pieza_inglaterra_recogida: bool = false
var hablo_con_ingles: bool = false
var oveja_en_redil: bool = false
var ingles_completado: bool = false
var pieza_japon_recogida: bool = false
var hablo_con_mono: bool = false
var onigiri_recogido: bool = false
var mono_completado: bool = false
var hablo_con_maestro: bool = false
var tablones_rotos: int = 0
var leccion_doble_salto_completada: bool = false
var doble_salto_aprendido: bool = false
var dianas_golpeadas: int = 0
var leccion_patada_completada: bool = false
var patada_voladora_aprendida: bool = false
var hablo_con_lama: bool = false
var rocas_rotas: int = 0
var leccion_grito_completada: bool = false
var grito_aprendido: bool = false
var yetis_congelados: int = 0
var leccion_hielo_completada: bool = false
var hielo_aprendido: bool = false
var cueva_abierta: bool = false
var hablo_con_ali: bool = false
var tesoro_recogido: bool = false
var mision_ali_completada: bool = false
var vidas: int = 3
var sellos_recogidos: int = 0
var sellos_completados: bool = false
var deseos_recogidos: int = 0
var genio_completado: bool = false
var lampara_obtenida: bool = false
var talisman_obtenido: bool = false
var boss_derrotado: bool = false
var juego_completado: bool = false
var dialogo_abierto: bool = false
var punto_aparicion: String = ""
var zona_actual: String = "Pueblo"

var vestuario_desbloqueado: Dictionary = {
	"sombrero": [],
	"gafas": [],
	"guantes": [],
	"corbata": [],
	"camisa": [],
	"lampara": [],
}

var vestuario_equipado: Dictionary = {
	"sombrero": "",
	"gafas": "",
	"guantes": "",
	"corbata": "",
	"camisa": "",
	"lampara": "",
}


const RUTA_GUARDADO := "user://partida.cfg"

## Variables que no se guardan (estado momentáneo de la sesión).
const NO_GUARDAR := [
	"dialogo_abierto", "punto_aparicion", "zona_actual", "vestuario_equipado",
	"vestuario_desbloqueado",
]


var escena_guardada: String = ""
var pos_guardada: Vector2 = Vector2.ZERO
var hay_pos_guardada: bool = false
var _en_transicion: bool = false
var _iniciando: bool = true
var _temporizador: Timer


func _ready() -> void:
	if DESBLOQUEAR_TODO:
		cueva_abierta = true
	cargar_partida()
	if mision_ali_completada and not talisman_obtenido:
		talisman_obtenido = true
	if lampara_obtenida and not "lampara" in vestuario_desbloqueado["lampara"]:
		vestuario_desbloqueado["lampara"].append("lampara")
	mision_actualizada.connect(guardar_partida)

	_temporizador = Timer.new()
	_temporizador.wait_time = 15.0
	_temporizador.autostart = true
	_temporizador.timeout.connect(_autoguardar)
	add_child(_temporizador)

	while get_tree().current_scene == null:
		await get_tree().process_frame
	if not escena_guardada.is_empty() and escena_guardada != "res://escenas/pueblo.tscn" \
			and ResourceLoader.exists(escena_guardada):
		get_tree().change_scene_to_file(escena_guardada)
		await get_tree().process_frame
	await _aplicar_pos_guardada()
	await get_tree().create_timer(0.2).timeout
	_iniciando = false


func _aplicar_pos_guardada() -> void:
	if not hay_pos_guardada:
		return
	for i in range(120):
		await get_tree().process_frame
		var escena := get_tree().current_scene
		if escena == null or escena.scene_file_path != escena_guardada:
			continue
		var jugador := escena.get_node_or_null("Jugador")
		if jugador is Node2D:
			(jugador as Node2D).global_position = pos_guardada + Vector2(0, -2)
			hay_pos_guardada = false
			return


func _autoguardar() -> void:
	if get_tree().paused:
		return
	var escena := get_tree().current_scene
	if escena == null:
		return
	var jugador := escena.get_node_or_null("Jugador")
	if jugador is CharacterBody2D and (jugador as CharacterBody2D).is_on_floor():
		guardar_partida()


func _notification(que: int) -> void:
	if que == NOTIFICATION_WM_CLOSE_REQUEST and is_inside_tree():
		guardar_partida()


func guardar_partida() -> void:
	if _iniciando:
		return
	if not _en_transicion:
		var escena := get_tree().current_scene
		if escena != null and not escena.scene_file_path.is_empty():
			escena_guardada = escena.scene_file_path
			var jugador := escena.get_node_or_null("Jugador")
			if jugador != null:
				pos_guardada = (jugador as Node2D).global_position
				hay_pos_guardada = true

	var cfg := ConfigFile.new()
	for dato in get_property_list():
		if dato["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE == 0:
			continue
		if dato["name"] in NO_GUARDAR or str(dato["name"]).begins_with("_"):
			continue
		if dato["type"] in [TYPE_BOOL, TYPE_INT, TYPE_STRING]:
			cfg.set_value("progreso", dato["name"], get(dato["name"]))
	cfg.set_value("progreso", "__escena", escena_guardada)
	cfg.set_value("progreso", "__pos_x", pos_guardada.x)
	cfg.set_value("progreso", "__pos_y", pos_guardada.y)
	cfg.set_value("progreso", "__hay_pos", hay_pos_guardada)
	cfg.save(RUTA_GUARDADO)
	partida_guardada.emit()


func cargar_partida() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(RUTA_GUARDADO) != OK:
		return false
	for clave in cfg.get_section_keys("progreso"):
		if clave in NO_GUARDAR or clave.begins_with("_"):
			continue
		set(clave, cfg.get_value("progreso", clave))
	escena_guardada = cfg.get_value("progreso", "__escena", "")
	pos_guardada = Vector2(cfg.get_value("progreso", "__pos_x", 0.0),
			cfg.get_value("progreso", "__pos_y", 0.0))
	hay_pos_guardada = cfg.get_value("progreso", "__hay_pos", false)
	return true


func recoger_sello() -> void:
	if sellos_recogidos >= 3 or sellos_completados:
		return
	sellos_recogidos += 1
	mision_actualizada.emit()


func completar_sellos() -> void:
	if sellos_completados:
		return
	sellos_completados = true
	if vidas < 5:
		vidas += 1
		vidas_cambiadas.emit()
	mision_actualizada.emit()


func perder_vida() -> void:
	vidas -= 1
	vidas_cambiadas.emit()


func reiniciar_vidas() -> void:
	vidas = 3
	vidas_cambiadas.emit()


func recoger_deseo() -> void:
	if deseos_recogidos >= 3 or genio_completado:
		return
	deseos_recogidos += 1
	mision_actualizada.emit()


func completar_genio() -> void:
	if genio_completado:
		return
	genio_completado = true
	lampara_obtenida = true
	if vidas < 5:
		vidas += 1
		vidas_cambiadas.emit()
	if not "lampara" in vestuario_desbloqueado["lampara"]:
		vestuario_desbloqueado["lampara"].append("lampara")
	vestuario_cambiado.emit()
	mision_actualizada.emit()


func borrar_guardado() -> void:
	escena_guardada = ""
	pos_guardada = Vector2.ZERO
	hay_pos_guardada = false
	if FileAccess.file_exists(RUTA_GUARDADO):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUTA_GUARDADO))


func ir_a_escena(ruta_escena: String, id_punto_aparicion: String = "") -> void:
	punto_aparicion = id_punto_aparicion
	_en_transicion = true
	escena_guardada = ruta_escena
	hay_pos_guardada = false
	guardar_partida()
	_en_transicion = false
	get_tree().call_deferred("change_scene_to_file", ruta_escena)


func registrar_charla_npc() -> void:
	if not hablo_con_npc:
		hablo_con_npc = true
		mision_actualizada.emit()


func recoger_estrella() -> void:
	if not estrella_recogida:
		estrella_recogida = true
		mision_actualizada.emit()


func completar_mision() -> void:
	if not mision_completada:
		mision_completada = true
		desbloquear_prenda("sombrero", "corona")
		desbloquear_prenda("camisa", "rayas")
		mision_actualizada.emit()


func registrar_charla_quesito() -> void:
	if not hablo_con_quesito:
		hablo_con_quesito = true
		mision_actualizada.emit()


func marcar_rayo_en_caja() -> void:
	if not rayo_en_caja:
		rayo_en_caja = true
		mision_actualizada.emit()


func completar_mision_quesito() -> void:
	if not mision_quesito_completada:
		mision_quesito_completada = true
		desbloquear_prenda("sombrero", "helice")
		desbloquear_prenda("gafas", "estrella")
		mision_actualizada.emit()


func desbloquear_prenda(categoria: String, id_item: String) -> void:
	if not vestuario_desbloqueado.has(categoria):
		vestuario_desbloqueado[categoria] = []
	var lista: Array = vestuario_desbloqueado[categoria]
	if not lista.has(id_item):
		lista.append(id_item)
		vestuario_cambiado.emit()


func desbloquear_accesorio(categoria: String, id_item: String) -> void:
	desbloquear_prenda(categoria, id_item)


func esta_desbloqueado(categoria: String, id_item: String) -> bool:
	if id_item.is_empty():
		return true
	if not vestuario_desbloqueado.has(categoria):
		return false
	return (vestuario_desbloqueado[categoria] as Array).has(id_item)


func equipar_accesorio(categoria: String, id_item: String) -> void:
	if not esta_desbloqueado(categoria, id_item):
		return
	if vestuario_equipado.get(categoria, "") == id_item:
		vestuario_equipado[categoria] = ""
	else:
		vestuario_equipado[categoria] = id_item
	vestuario_cambiado.emit()


func obtener_equipado(categoria: String) -> String:
	return str(vestuario_equipado.get(categoria, ""))


func sumar_pieza_brillante() -> void:
	if piezas_brillantes < TOTAL_PIEZAS:
		piezas_brillantes += 1
		mision_actualizada.emit()


func registrar_charla_alcalde() -> void:
	if not hablo_con_alcalde:
		hablo_con_alcalde = true
		mision_actualizada.emit()


func recoger_carta_tejados() -> void:
	if not carta_tejados_recogida:
		carta_tejados_recogida = true
		mision_actualizada.emit()


func completar_vecino1() -> void:
	if not vecino1_completado:
		vecino1_completado = true
		desbloquear_prenda("gafas", "sol")
		mision_actualizada.emit()


func completar_vecino2() -> void:
	if not vecino2_completado:
		vecino2_completado = true
		desbloquear_prenda("corbata", "corbata")
		desbloquear_prenda("guantes", "blancos")
		mision_actualizada.emit()


func recoger_pieza_austria() -> void:
	if not pieza_austria_recogida:
		pieza_austria_recogida = true
		sumar_pieza_brillante()


func registrar_charla_vaca() -> void:
	if not hablo_con_vaca:
		hablo_con_vaca = true
		mision_actualizada.emit()


func recoger_flor_vaca() -> void:
	if not flor_vaca_recogida:
		flor_vaca_recogida = true
		mision_actualizada.emit()


func completar_vaca() -> void:
	if not vaca_completada:
		vaca_completada = true
		desbloquear_prenda("sombrero", "tiroles")
		mision_actualizada.emit()


func recoger_pieza_selva() -> void:
	if not pieza_selva_recogida:
		pieza_selva_recogida = true
		sumar_pieza_brillante()


func registrar_charla_enanito() -> void:
	if not hablo_con_enanito:
		hablo_con_enanito = true
		mision_actualizada.emit()


func recoger_bellota() -> void:
	if not bellota_recogida:
		bellota_recogida = true
		mision_actualizada.emit()


func completar_enanito() -> void:
	if not enanito_completado:
		enanito_completado = true
		desbloquear_prenda("camisa", "rayas")
		desbloquear_prenda("sombrero", "copa")
		mision_actualizada.emit()


func recoger_pieza_inglaterra() -> void:
	if not pieza_inglaterra_recogida:
		pieza_inglaterra_recogida = true
		sumar_pieza_brillante()


func registrar_charla_ingles() -> void:
	if not hablo_con_ingles:
		hablo_con_ingles = true
		mision_actualizada.emit()


func marcar_oveja_en_redil() -> void:
	if not oveja_en_redil:
		oveja_en_redil = true
		mision_actualizada.emit()


func completar_ingles() -> void:
	if not ingles_completado:
		ingles_completado = true
		desbloquear_prenda("sombrero", "bombin")
		desbloquear_prenda("guantes", "blancos")
		mision_actualizada.emit()


func recoger_pieza_japon() -> void:
	if not pieza_japon_recogida:
		pieza_japon_recogida = true
		sumar_pieza_brillante()


func registrar_charla_mono() -> void:
	if not hablo_con_mono:
		hablo_con_mono = true
		mision_actualizada.emit()


func recoger_onigiri() -> void:
	if not onigiri_recogido:
		onigiri_recogido = true
		mision_actualizada.emit()


func completar_mono() -> void:
	if not mono_completado:
		mono_completado = true
		desbloquear_prenda("sombrero", "ninja")
		desbloquear_prenda("gafas", "estrella")
		mision_actualizada.emit()


func registrar_charla_maestro() -> void:
	if not hablo_con_maestro:
		hablo_con_maestro = true
		mision_actualizada.emit()


func romper_tablon() -> void:
	if tablones_rotos >= TABLONES_MISION:
		return
	tablones_rotos += 1
	mision_actualizada.emit()
	if tablones_rotos >= TABLONES_MISION and not leccion_doble_salto_completada:
		# La lección se sella al volver a hablar con el maestro.
		pass


func golpear_diana() -> void:
	if dianas_golpeadas >= DIANAS_MISION:
		return
	dianas_golpeadas += 1
	mision_actualizada.emit()


func completar_leccion_doble_salto() -> void:
	if leccion_doble_salto_completada:
		return
	leccion_doble_salto_completada = true
	doble_salto_aprendido = true
	mision_actualizada.emit()


func completar_leccion_patada_voladora() -> void:
	if leccion_patada_completada:
		return
	leccion_patada_completada = true
	patada_voladora_aprendida = true
	mision_actualizada.emit()


func registrar_charla_lama() -> void:
	if not hablo_con_lama:
		hablo_con_lama = true
		mision_actualizada.emit()


func romper_roca() -> void:
	if rocas_rotas >= ROCAS_MISION:
		return
	rocas_rotas += 1
	mision_actualizada.emit()


func aprender_grito() -> void:
	if grito_aprendido:
		return
	grito_aprendido = true
	mision_actualizada.emit()


func aprender_hielo() -> void:
	if hielo_aprendido:
		return
	hielo_aprendido = true
	mision_actualizada.emit()


func completar_leccion_grito() -> void:
	if leccion_grito_completada:
		return
	leccion_grito_completada = true
	grito_aprendido = true
	mision_actualizada.emit()


func congelar_yeti() -> void:
	if yetis_congelados >= YETIS_MISION:
		return
	yetis_congelados += 1
	mision_actualizada.emit()


func completar_leccion_hielo() -> void:
	if leccion_hielo_completada:
		return
	leccion_hielo_completada = true
	hielo_aprendido = true
	mision_actualizada.emit()


func registrar_charla_ali() -> void:
	if not hablo_con_ali:
		hablo_con_ali = true
		mision_actualizada.emit()


func abrir_cueva() -> void:
	if not cueva_abierta:
		cueva_abierta = true
		mision_actualizada.emit()


func recoger_tesoro() -> void:
	if not tesoro_recogido:
		tesoro_recogido = true
		mision_actualizada.emit()


func completar_mision_ali() -> void:
	talisman_obtenido = true
	if mision_ali_completada:
		return
	mision_ali_completada = true
	mision_actualizada.emit()


func derrotar_boss() -> void:
	if not boss_derrotado:
		boss_derrotado = true
		juego_completado = true
		desbloquear_prenda("sombrero", "corona")
		mision_actualizada.emit()


func reiniciar_estado() -> void:
	piezas_brillantes = 0
	hablo_con_alcalde = false
	carta_tejados_recogida = false
	vecino1_completado = false
	vecino2_completado = false
	hablo_con_npc = false
	estrella_recogida = false
	mision_completada = false
	hablo_con_quesito = false
	rayo_en_caja = false
	mision_quesito_completada = false
	pieza_austria_recogida = false
	hablo_con_vaca = false
	flor_vaca_recogida = false
	vaca_completada = false
	pieza_selva_recogida = false
	hablo_con_enanito = false
	bellota_recogida = false
	enanito_completado = false
	pieza_inglaterra_recogida = false
	hablo_con_ingles = false
	oveja_en_redil = false
	ingles_completado = false
	pieza_japon_recogida = false
	hablo_con_mono = false
	onigiri_recogido = false
	mono_completado = false
	hablo_con_maestro = false
	tablones_rotos = 0
	leccion_doble_salto_completada = false
	doble_salto_aprendido = false
	dianas_golpeadas = 0
	leccion_patada_completada = false
	patada_voladora_aprendida = false
	hablo_con_lama = false
	rocas_rotas = 0
	leccion_grito_completada = false
	grito_aprendido = false
	yetis_congelados = 0
	leccion_hielo_completada = false
	hielo_aprendido = false
	cueva_abierta = false
	hablo_con_ali = false
	tesoro_recogido = false
	mision_ali_completada = false
	talisman_obtenido = false
	deseos_recogidos = 0
	sellos_recogidos = 0
	sellos_completados = false
	vidas = 3
	genio_completado = false
	lampara_obtenida = false
	boss_derrotado = false
	juego_completado = false
	dialogo_abierto = false
	if DESBLOQUEAR_TODO:
		cueva_abierta = true
	mision_actualizada.emit()
