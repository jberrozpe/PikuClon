extends Node2D
## Fondo de colinas con paralaje para el pueblo y Austria.

@export_enum("pueblo", "austria", "espana", "selva", "queso") var estilo: String = "pueblo"
@export var ancho: float = 2400.0
@export var alto: float = 700.0
@export var semilla: int = 5

var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = semilla
	_cielo()
	_capa(0.12, Vector2.ZERO)
	_sol()
	_colinas(0.30, 360.0, 150.0, _c1(), _c1_clara(), 0.0045)
	_colinas(0.55, 470.0, 110.0, _c2(), _c2_clara(), 0.006)
	_nubes()


func _cielo() -> void:
	var arriba := Color("8fc4ee")
	var abajo := Color("dff0fb")
	match estilo:
		"austria":
			arriba = Color("a9cfe8"); abajo = Color("eaf4fb")
		"espana":
			arriba = Color("f4c07c"); abajo = Color("ffe8bf")
		"selva":
			arriba = Color("2e4a3e"); abajo = Color("7fa98a")
		"queso":
			arriba = Color("f7d98a"); abajo = Color("fff3cf")
	var cielo := Polygon2D.new()
	cielo.polygon = PackedVector2Array([
		Vector2(-600, -900), Vector2(ancho + 600, -900),
		Vector2(ancho + 600, alto + 400), Vector2(-600, alto + 400),
	])
	cielo.vertex_colors = PackedColorArray([arriba, arriba, abajo, abajo])
	add_child(cielo)


func _c1() -> Color:
	match estilo:
		"austria":
			return Color("8fa9c4")
		"espana":
			return Color("d9a45e")
		"selva":
			return Color("3f6b4e")
		"queso":
			return Color("9fce5c")
	return Color("7ec850")


func _c1_clara() -> Color:
	match estilo:
		"austria":
			return Color("f2f7fc")
		"espana":
			return Color("f0cb8a")
		"selva":
			return Color("6c9a74")
		"queso":
			return Color("c4e88a")
	return Color("a5dd6e")


func _c2() -> Color:
	match estilo:
		"austria":
			return Color("6f8aa8")
		"espana":
			return Color("b8803f")
		"selva":
			return Color("2c5039")
		"queso":
			return Color("7cb544")
	return Color("5aa83a")


func _c2_clara() -> Color:
	match estilo:
		"austria":
			return Color("e2ecf5")
		"espana":
			return Color("d9a666")
		"selva":
			return Color("4f7d5a")
		"queso":
			return Color("a2d466")
	return Color("8ac95c")


func _capa(factor: float, _nada: Vector2) -> void:
	var p := Parallax2D.new()
	p.scroll_scale = Vector2(factor, 1.0)
	add_child(p)
	if factor < 0.2:
		_destino_sol = p


var _destino_sol: Parallax2D


func _sol() -> void:
	if _destino_sol == null:
		return
	var gradiente := Gradient.new()
	var tono := Color("fff3c4") if estilo == "pueblo" else Color("f7fbff")
	gradiente.set_color(0, Color(tono.r, tono.g, tono.b, 0.9))
	gradiente.set_color(1, Color(tono.r, tono.g, tono.b, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = gradiente
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 256
	tex.height = 256
	var halo := Sprite2D.new()
	halo.texture = tex
	halo.position = Vector2(2100, 150)
	halo.scale = Vector2(2.2, 2.2)
	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	halo.material = mat
	_destino_sol.add_child(halo)
	var disco := Polygon2D.new()
	disco.polygon = _circulo(52.0, 32)
	disco.color = Color("fff6d0") if estilo == "pueblo" else Color("ffffff")
	disco.position = Vector2(2100, 150)
	_destino_sol.add_child(disco)


func _colinas(factor: float, base_y: float, alto_colina: float, color: Color,
		color_clara: Color, frecuencia: float) -> void:
	var paralaje := Parallax2D.new()
	paralaje.scroll_scale = Vector2(factor, 1.0)
	add_child(paralaje)
	var ancho_capa := ancho * factor
	var puntos := PackedVector2Array()
	var x := -900.0
	while x <= ancho_capa + 900.0:
		var y := base_y - (sin(x * frecuencia) * 0.5 + 0.5) * alto_colina
		puntos.append(Vector2(x, y))
		x += 40.0
	var cuerpo := puntos.duplicate()
	cuerpo.append(Vector2(ancho_capa + 900.0, alto + 300.0))
	cuerpo.append(Vector2(-900.0, alto + 300.0))
	var colina := Polygon2D.new()
	colina.polygon = cuerpo
	colina.color = color
	paralaje.add_child(colina)

	var cresta := Polygon2D.new()
	var cima := PackedVector2Array()
	for i in range(puntos.size()):
		cima.append(puntos[i])
	for i in range(puntos.size() - 1, -1, -1):
		cima.append(puntos[i] + Vector2(0, 16))
	cresta.polygon = cima
	cresta.color = color_clara
	paralaje.add_child(cresta)

	if estilo == "austria":
		for i in range(0, puntos.size(), 3):
			if i + 1 < puntos.size():
				var nieve := Polygon2D.new()
				var p := puntos[i]
				nieve.polygon = PackedVector2Array([
					p + Vector2(-26, 4), p + Vector2(0, -14), p + Vector2(26, 4),
					p + Vector2(10, 10), p + Vector2(0, 4), p + Vector2(-10, 10),
				])
				nieve.color = Color("ffffff")
				paralaje.add_child(nieve)


func _nubes() -> void:
	for i in range(4):
		var cx := _rng.randf_range(0.0, ancho * 0.3)
		var cy := _rng.randf_range(70.0, 210.0)
		var r := _rng.randf_range(26.0, 40.0)
		var nube := Node2D.new()
		_destino_sol.add_child(nube)
		for k in range(3):
			var bola := Polygon2D.new()
			var radio := r * (1.0 if k == 1 else 0.72)
			bola.polygon = _circulo(radio, 20)
			bola.position = Vector2(cx + (k - 1) * r * 0.85, cy + (0 if k == 1 else r * 0.25))
			bola.color = Color(1, 1, 1, 0.9)
			nube.add_child(bola)
		var base := Polygon2D.new()
		base.polygon = PackedVector2Array([
			Vector2(cx - r * 1.5, cy + r * 0.55), Vector2(cx + r * 1.5, cy + r * 0.55),
			Vector2(cx + r * 1.5, cy + r * 0.3), Vector2(cx - r * 1.5, cy + r * 0.3),
		])
		base.color = Color(1, 1, 1, 0.9)
		nube.add_child(base)


func _circulo(radio: float, lados: int) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(lados):
		var angulo := TAU * float(i) / float(lados)
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	return puntos
