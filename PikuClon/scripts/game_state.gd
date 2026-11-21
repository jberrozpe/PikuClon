extends Node

signal mision_actualizada
signal vestuario_cambiado

var hablo_con_npc: bool = false
var estrella_recogida: bool = false
var mision_completada: bool = false
var hablo_con_quesito: bool = false
var rayo_en_caja: bool = false
var mision_quesito_completada: bool = false
var punto_aparicion: String = ""
var zona_actual: String = "Pueblo"

var vestuario_desbloqueado: Dictionary = {
	"sombrero": ["copa", "helice"],
	"gafas": ["sol", "estrella"],
	"guantes": ["blancos"],
	"corbata": ["corbata"],
	"camisa": ["rayas"],
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
		desbloquear_accesorio("sombrero", "corona")
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
		desbloquear_accesorio("sombrero", "corona")
		mision_actualizada.emit()


func desbloquear_accesorio(categoria: String, id_item: String) -> void:
	if not vestuario_desbloqueado.has(categoria):
		vestuario_desbloqueado[categoria] = []
	var lista: Array = vestuario_desbloqueado[categoria]
	if not lista.has(id_item):
		lista.append(id_item)
		vestuario_cambiado.emit()


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


func reiniciar_estado() -> void:
	hablo_con_npc = false
	estrella_recogida = false
	mision_completada = false
	hablo_con_quesito = false
	rayo_en_caja = false
	mision_quesito_completada = false
	mision_actualizada.emit()
