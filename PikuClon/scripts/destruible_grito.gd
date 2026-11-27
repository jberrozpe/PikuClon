extends StaticBody2D
## Roca o puerta sellada que se destruye con el grito gutural.

@export var cuenta_roca: bool = false
@export var bandera: String = ""
@export var color_trozos: Color = Color("8c93a8")
@export var tamano_trozos: int = 10

var _roto: bool = false

@onready var visual: Node2D = $Visual
@onready var sonido: AudioStreamPlayer = get_node_or_null("Sonido")


func _ready() -> void:
	add_to_group("destruible")
	if not bandera.is_empty() and bool(GameState.get(bandera)):
		queue_free()


func recibir_grito(direccion: float) -> void:
	if _roto:
		return
	_roto = true
	GameState.dialogo_abierto = false
	if sonido != null:
		sonido.play()
	Efectos.trozos(global_position, color_trozos, tamano_trozos, 130.0)
	Efectos.anillo(global_position, color_trozos.lightened(0.35), 120.0, 6.0, 0.5)
	Efectos.destello(global_position, Color(1, 1, 1, 0.9), 40.0)

	if cuenta_roca:
		GameState.romper_roca()
	if not bandera.is_empty():
		GameState.set(bandera, true)
		GameState.mision_actualizada.emit()

	$CollisionShape2D.set_deferred("disabled", true)
	if visual != null:
		var tw := create_tween()
		tw.set_parallel(true)
		tw.tween_property(visual, "modulate:a", 0.0, 0.25)
		tw.tween_property(visual, "scale", Vector2(1.15, 0.85), 0.25)
		await tw.finished
	queue_free()
