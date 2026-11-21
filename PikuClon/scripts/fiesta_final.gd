extends Node2D

const COLORES_FUEGOS := [
	Color(0.901961, 0.223529, 0.27451, 1),
	Color(1, 0.819608, 0.25098, 1),
	Color(0.180392, 0.768627, 0.713725, 1),
	Color(0.247059, 0.54902, 0.878431, 1),
	Color(0.945098, 0.356863, 0.709804, 1),
]

var _tiempo_cohete: float = 0.0
var _particulas: Array[Dictionary] = []

@onready var contenedor_fuegos: Node2D = $FuegosArtificiales
@onready var sonido_cohete: AudioStreamPlayer = $SonidoCohete


func _ready() -> void:
	_lanzar_fuego()


func _process(delta: float) -> void:
	_tiempo_cohete += delta
	if _tiempo_cohete >= 0.9:
		_tiempo_cohete = 0.0
		_lanzar_fuego()

	var restantes: Array[Dictionary] = []
	for p in _particulas:
		var nodo: Polygon2D = p["nodo"]
		p["vida"] -= delta
		if p["vida"] > 0.0:
			p["vel"].y += 220.0 * delta
			nodo.position += p["vel"] * delta
			nodo.modulate.a = clampf(p["vida"] / 1.2, 0.0, 1.0)
			restantes.append(p)
		else:
			nodo.queue_free()
	_particulas = restantes


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ENTER or event.keycode == KEY_E:
			GameState.ir_a_escena("res://escenas/pueblo.tscn", "")


func _lanzar_fuego() -> void:
	var centro := Vector2(randf_range(160.0, 990.0), randf_range(90.0, 260.0))
	var color: Color = COLORES_FUEGOS[randi() % COLORES_FUEGOS.size()]
	if sonido_cohete:
		sonido_cohete.play()

	for i in range(14):
		var angulo := (TAU / 14.0) * i + randf_range(-0.15, 0.15)
		var vel := Vector2(cos(angulo), sin(angulo)) * randf_range(90.0, 190.0)
		var chispa := Polygon2D.new()
		chispa.polygon = PackedVector2Array([-4, -4, 4, -4, 4, 4, -4, 4])
		chispa.color = color
		chispa.position = centro
		contenedor_fuegos.add_child(chispa)
		_particulas.append({
			"nodo": chispa,
			"vel": vel,
			"vida": randf_range(0.8, 1.3),
		})
