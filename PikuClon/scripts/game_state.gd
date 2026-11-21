extends Node

signal mision_actualizada
signal vestuario_cambiado

const TOTAL_PIEZAS: int = 4

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
var punto_aparicion: String = ""
var zona_actual: String = "Pueblo"

var vestuario_desbloqueado: Dictionary = {
	"sombrero": [],
	"gafas": [],
	"guantes": [],
	"corbata": [],
	"camisa": [],
}

var vestuario_equipado: Dictionary = {
	"sombrero": "",
	"gafas": "",
	"guantes": "",
	"corbata": "",
	"camisa": "",
}


func ir_a_escena(ruta_escena: String, id_punto_aparicion: String = "") -> void:
	punto_aparicion = id_punto_aparicion
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
	mision_actualizada.emit()
