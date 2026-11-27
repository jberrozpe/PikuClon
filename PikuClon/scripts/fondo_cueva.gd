extends Node2D
## Fondo de cueva: degradado cálido + dos capas de roca con paralaje.

@export var ancho: float = 2100.0
@export var alto: float = 1200.0
@export var semilla: int = 11

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = semilla
	_capa(0.35, Color("3A2118"), 0.55, 210.0)
	_capa(0.6, Color("51301F"), 0.8, 150.0)


func _degradado() -> void:
	var quad := Polygon2D.new()
	quad.polygon = PackedVector2Array([
		Vector2(-500, -500), Vector2(ancho + 500, -500),
		Vector2(ancho + 500, alto + 500), Vector2(-500, alto + 500),
	])
	quad.vertex_colors = PackedColorArray([
		Color("2A1610"), Color("2A1610"), Color("4A2A1A"), Color("4A2A1A"),
	])
	add_child(quad)


func _capa(factor: float, color: Color, densidad: float, tamano: float) -> void:
	var paralaje := Parallax2D.new()
	paralaje.scroll_scale = Vector2(factor, 1.0)
	add_child(paralaje)

	var ancho_capa := ancho * factor
	var x := -250.0
	while x < ancho_capa + 250.0:
		var radio := tamano * _rng.randf_range(0.7, 1.3)
		var roca := Polygon2D.new()
		roca.polygon = _circulo(radio, 14)
		var base := alto * (0.9 if factor < 0.5 else 0.96)
		roca.position = Vector2(x, base - radio * _rng.randf_range(0.2, 0.55))
		roca.color = color
		paralaje.add_child(roca)

		# estalactita colgando del techo
		if _rng.randf() < densidad:
			var pico := Polygon2D.new()
			var ancho_pico := radio * 0.7
			var techo := 430.0 if factor < 0.5 else 300.0
			pico.polygon = PackedVector2Array([
				Vector2(x - ancho_pico * 0.5, techo),
				Vector2(x, techo + radio * _rng.randf_range(1.0, 2.2)),
				Vector2(x + ancho_pico * 0.5, techo),
			])
			pico.color = color
			paralaje.add_child(pico)

		x += radio * 1.15


func _circulo(radio: float, lados: int) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(lados):
		var angulo := TAU * float(i) / float(lados)
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	return puntos
