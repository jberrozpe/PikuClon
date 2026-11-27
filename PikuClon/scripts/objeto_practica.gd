extends Area2D
## Objeto de entrenamiento del maestro de karate.
##
## - "tablon": se rompe con una patada normal.
## - "diana": solo cede ante una patada voladora en el aire.

@export_enum("tablon", "diana") var tipo: String = "tablon"
@export var indice: int = 0
@export var color_golpe: Color = Color(0.98, 0.78, 0.35)

var _roto: bool = false
var _balanceo: float = 0.0

@onready var visual: Node2D = $Visual
@onready var sonido: AudioStreamPlayer = $Sonido


func _ready() -> void:
	# Los objetos ya superados no reaparecen al volver al nivel.
	var hechos := GameState.tablones_rotos if tipo == "tablon" else GameState.dianas_golpeadas
	if indice < hechos:
		queue_free()
		return
	_balanceo = randf() * TAU


func _process(delta: float) -> void:
	if tipo == "diana" and not _roto:
		_balanceo += delta * 1.7
		visual.rotation = sin(_balanceo) * 0.1


func recibir_patada(tipo_golpe: String) -> void:
	if _roto:
		return

	if tipo == "diana" and tipo_golpe != "voladora" and tipo_golpe != "aereo":
		# La diana se tambalea: hay que golpearla en el aire.
		Efectos.chispas(global_position, Color(1, 0.9, 0.5), 5, 26.0, 0.25)
		_temblor()
		return

	_roto = true
	$CollisionShape2D.set_deferred("disabled", true)
	sonido.play()
	Efectos.trozos(global_position, color_golpe, 7, 95.0)
	Efectos.anillo(global_position, color_golpe, 74.0)
	Efectos.destello(global_position, Color(1, 1, 1, 0.9), 30.0)
	visual.visible = false

	if tipo == "tablon":
		GameState.romper_tablon()
	else:
		GameState.golpear_diana()

	await sonido.finished
	queue_free()


func _temblor() -> void:
	if visual == null:
		return
	var base := visual.position
	var tw := create_tween()
	tw.tween_property(visual, "position", base + Vector2(4, 0), 0.05)
	tw.tween_property(visual, "position", base - Vector2(4, 0), 0.05)
	tw.tween_property(visual, "position", base, 0.06)
