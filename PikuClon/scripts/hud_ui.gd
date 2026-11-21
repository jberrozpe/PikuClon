extends CanvasLayer

@onready var etiqueta_piezas: Label = $Contenedor/CajaPiezas/EtiquetaPiezas


func _ready() -> void:
	GameState.mision_actualizada.connect(_actualizar_hud)
	_actualizar_hud()


func _actualizar_hud() -> void:
	etiqueta_piezas.text = "Piezas Brillantes: %d/%d" % [GameState.piezas_brillantes, GameState.TOTAL_PIEZAS]
