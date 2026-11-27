extends Node
## Sustituye los rectángulos planos de suelo y plataformas por formas suaves
## (nieve, arena o piedra) con contorno, brillo superior y montoncitos.

@export_enum("nieve", "arena", "piedra", "hierba", "selva") var material: String = "nieve"

var _paleta := {}


func _ready() -> void:
	_paleta = _elegir_paleta()
	var escena := get_parent()
	for nodo in escena.get_children():
		if nodo is StaticBody2D:
			_vestir(nodo)


func _elegir_paleta() -> Dictionary:
	match material:
		"arena":
			return {
				"cuerpo": Color("eac382"), "banda": Color("f7dfae"),
				"sombra": Color("d3a967"), "borde": Color("6b5433"),
			}
		"hierba":
			return {
				"cuerpo": Color("6fbf4a"), "banda": Color("8fd96a"),
				"sombra": Color("4e8f35"), "borde": Color("2c5a22"),
			}
		"selva":
			return {
				"cuerpo": Color("3f6b45"), "banda": Color("5b8c5c"),
				"sombra": Color("2b4c31"), "borde": Color("16281b"),
			}
		"piedra":
			return {
				"cuerpo": Color("6b647a"), "banda": Color("8c84a0"),
				"sombra": Color("4e4859"), "borde": Color("1d1e26"),
			}
		_:
			return {
				"cuerpo": Color("f7fbff"), "banda": Color("ffffff"),
				"sombra": Color("d6e4f4"), "borde": Color("55677a"),
			}


func _vestir(cuerpo: StaticBody2D) -> void:
	var colision := cuerpo.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if colision == null or not (colision.shape is RectangleShape2D):
		return
	var caja := (colision.shape as RectangleShape2D).size
	if caja.y > caja.x * 1.5:
		return
	var visual := cuerpo.get_node_or_null("Visual")
	if visual is CanvasItem:
		(visual as CanvasItem).visible = false

	var tam: Vector2 = (colision.shape as RectangleShape2D).size
	var capa := Node2D.new()
	capa.name = "Terreno"
	capa.position = colision.position
	cuerpo.add_child(capa)

	if tam.x > 1200.0:
		_suelo(capa, tam)
	else:
		_plataforma(capa, tam)


func _plataforma(capa: Node2D, tam: Vector2) -> void:
	var ancho := tam.x
	var alto := tam.y
	var puntos := _repisa(ancho, alto)

	var cuerpo := Polygon2D.new()
	cuerpo.polygon = puntos
	cuerpo.color = _paleta["cuerpo"]
	capa.add_child(cuerpo)

	# Canto inferior: sombra fina siguiendo la base.
	var sombra := Polygon2D.new()
	sombra.polygon = _redondeado(ancho * 0.82, 6.0, 3.0)
	sombra.position = Vector2(0, alto * 0.5 - 4.0)
	sombra.color = _paleta["sombra"]
	capa.add_child(sombra)

	# Banda de brillo en la superficie.
	var banda := Polygon2D.new()
	banda.polygon = _redondeado(ancho - 14.0, 6.0, 3.0)
	banda.position = Vector2(0, -alto * 0.5 + 4.0)
	banda.color = _paleta["banda"]
	capa.add_child(banda)

	if material == "nieve":
		for i in range(3):
			var copo := Polygon2D.new()
			var r := 6.0 + float(i % 2) * 2.5
			copo.polygon = _circulo(r, 16)
			copo.position = Vector2(-ancho * 0.3 + float(i) * ancho * 0.3, -alto * 0.5)
			copo.color = _paleta["banda"]
			capa.add_child(copo)

	var borde := Line2D.new()
	borde.points = puntos
	borde.closed = true
	borde.width = 2.5
	borde.default_color = _paleta["borde"]
	borde.joint_mode = Line2D.LINE_JOINT_ROUND
	capa.add_child(borde)


func _repisa(ancho: float, alto: float) -> PackedVector2Array:
	var hw := ancho * 0.5
	var hh := alto * 0.5
	var puntos := PackedVector2Array()
	# Borde superior ondulado.
	var x := -hw + 8.0
	while x <= hw - 8.0:
		puntos.append(Vector2(x, -hh + sin(x * 0.05) * 1.6))
		x += 14.0
	# Esquina superior derecha y base más estrecha.
	puntos.append(Vector2(hw, -hh + 6.0))
	puntos.append(Vector2(hw - 3.0, hh - 7.0))
	puntos.append(Vector2(hw - 12.0, hh))
	puntos.append(Vector2(-hw + 12.0, hh))
	puntos.append(Vector2(-hw + 3.0, hh - 7.0))
	puntos.append(Vector2(-hw, -hh + 6.0))
	return puntos


func _suelo(capa: Node2D, tam: Vector2) -> void:
	var mitad := tam.x * 0.5
	var alto_mitad := tam.y * 0.5
	var topes := PackedVector2Array()
	var x := -mitad
	while x <= mitad:
		topes.append(Vector2(x, -alto_mitad + sin(x * 0.004) * 4.0))
		x += 40.0

	var cuerpo := Polygon2D.new()
	var puntos := PackedVector2Array(topes)
	puntos.append(Vector2(mitad, alto_mitad))
	puntos.append(Vector2(-mitad, alto_mitad))
	cuerpo.polygon = puntos
	cuerpo.color = _paleta["cuerpo"]
	capa.add_child(cuerpo)

	var banda := Polygon2D.new()
	var franja := PackedVector2Array(topes)
	for i in range(topes.size() - 1, -1, -1):
		franja.append(topes[i] + Vector2(0, 12.0))
	banda.polygon = franja
	banda.color = _paleta["banda"]
	capa.add_child(banda)

	var borde := Line2D.new()
	borde.points = topes
	borde.width = 2.5
	borde.default_color = _paleta["borde"]
	borde.joint_mode = Line2D.LINE_JOINT_ROUND
	capa.add_child(borde)

	if material == "nieve":
		for i in range(6):
			var copo := Polygon2D.new()
			var r := 9.0 + float(i % 3) * 3.0
			copo.polygon = _circulo(r, 18)
			copo.position = Vector2(-mitad + (i + 0.5) * tam.x / 6.0, -alto_mitad)
			copo.color = _paleta["banda"]
			capa.add_child(copo)


func _redondeado(ancho: float, alto: float, radio: float) -> PackedVector2Array:
	var hw := ancho * 0.5
	var hh := alto * 0.5
	var r: float = minf(radio, minf(hw, hh))
	var puntos := PackedVector2Array()
	var esquinas := [
		[Vector2(-hw + r, -hh + r), PI],
		[Vector2(hw - r, -hh + r), PI * 1.5],
		[Vector2(hw - r, hh - r), 0.0],
		[Vector2(-hw + r, hh - r), PI * 0.5],
	]
	for esquina in esquinas:
		var centro: Vector2 = esquina[0]
		var inicio: float = esquina[1]
		for paso in range(5):
			var angulo: float = inicio + PI * 0.5 * float(paso) / 4.0
			puntos.append(centro + Vector2(cos(angulo), sin(angulo)) * r)
	return puntos


func _circulo(radio: float, lados: int) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(lados):
		var angulo := TAU * float(i) / float(lados)
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	return puntos
