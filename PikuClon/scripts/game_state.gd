extends Node

signal mision_actualizada

var hablo_con_npc: bool = false
var estrella_recogida: bool = false
var mision_completada: bool = false


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
		mision_actualizada.emit()


func reiniciar_estado() -> void:
	hablo_con_npc = false
	estrella_recogida = false
	mision_completada = false
	mision_actualizada.emit()
