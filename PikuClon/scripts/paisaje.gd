extends Node2D
## Paisaje de fondo procedural: cielo degradado, sol con rayos animados,
## capas de montañas o dunas suaves y nubes. Se coloca justo después del
## fondo plano del nivel.

@export_enum("tibet", "arabia") var estilo: String = "tibet"
@export var ancho: float = 4400.0
@export var semilla: int = 7
@export var sol_x: float = 3200.0
@export var sol_y: float = 190.0
@export var sol_radio: float = 78.0

var _tiempo: float = 0.0
var _rayos: Node2D
var _halo: Polygon2D
var _rng := RandomNumberGenerator.new()
var _capas := {}
var _destino: Node2D
var _factor: float = 1.0

const VELOCIDADES := {"sol": 0.12, "lejano": 0.3, "medio": 0.55, "cercano": 0.75}


func _ready() -> void:
	_rng.seed = semilla
	_cielo()
	for nombre in VELOCIDADES:
		var capa := Parallax2D.new()
		capa.name = "Capa" + nombre.capitalize()
		capa.scroll_scale = Vector2(VELOCIDADES[nombre], 1.0)
		add_child(capa)
		_capas[nombre] = capa
	if estilo == "tibet":
		_usar("sol")
		_sol(Color("fff3c4"), Color("ffe08a"), 0.55)
		_montanas()
		_usar("lejano")
		_nubes(5, 0.9)
	else:
		_usar("sol")
		_sol(Color("fff0b8"), Color("ffca4a"), 1.0)
		_dunas()
		_usar("medio")
		_nubes(2, 0.6)


func _process(delta: float) -> void:
	_tiempo += delta
	if _rayos != null:
		_rayos.rotation += 0.16 * delta
	if _halo != null:
		_halo.scale = Vector2.ONE * (1.0 + 0.035 * sin(_tiempo * 1.7))
		_halo.modulate.a = 0.8 + 0.2 * sin(_tiempo * 1.3)


# ---------------------------------------------------------------- cielo
func _usar(nombre: String) -> void:
	_destino = _capas[nombre]
	_factor = VELOCIDADES[nombre]


func _cielo() -> void:
	var arriba: Color
	var abajo: Color
	if estilo == "tibet":
		arriba = Color("8fc4ee")
		abajo = Color("e8f4ff")
	else:
		arriba = Color("f2ae5c")
		abajo = Color("ffe2a6")

	var cielo := Polygon2D.new()
	cielo.name = "Cielo"
	cielo.polygon = PackedVector2Array([
		Vector2(-600.0, -1000.0), Vector2(ancho + 600.0, -1000.0),
		Vector2(ancho + 600.0, 900.0), Vector2(-600.0, 900.0),
	])
	cielo.vertex_colors = PackedColorArray([arriba, arriba, abajo, abajo])
	add_child(cielo)


# ---------------------------------------------------------------- sol
func _sol(tono: Color, borde: Color, fuerza: float) -> void:
	var sol := Node2D.new()
	sol.name = "Sol"
	sol.position = Vector2(sol_x * _factor, sol_y)
	if _destino != null:
		_destino.add_child(sol)
	else:
		add_child(sol)

	_halo = Polygon2D.new()
	_halo.polygon = _circulo(sol_radio * 2.4, 48)
	_halo.color = Color(borde.r, borde.g, borde.b, 0.22 * fuerza)
	sol.add_child(_halo)

	_rayos = Node2D.new()
	_rayos.name = "Rayos"
	sol.add_child(_rayos)
	for i in range(12):
		var largo := sol_radio * (1.35 if i % 2 == 0 else 1.05)
		var ancho_rayo := 9.0 if i % 2 == 0 else 6.0
		var rayo := Polygon2D.new()
		rayo.polygon = PackedVector2Array([
			Vector2(sol_radio * 0.92, 0),
			Vector2(largo, -ancho_rayo),
			Vector2(largo + 6.0, 0),
			Vector2(largo, ancho_rayo),
		])
		rayo.color = Color(borde.r, borde.g, borde.b, 0.55 * fuerza)
		rayo.rotation = TAU * float(i) / 12.0
		rayo.name = "Rayo%d" % i
		_rayos.add_child(rayo)

	var disco := Polygon2D.new()
	disco.polygon = _circulo(sol_radio, 48)
	disco.color = tono
	sol.add_child(disco)

	var brillo := Polygon2D.new()
	brillo.polygon = _circulo(sol_radio * 0.62, 32)
	brillo.color = Color(1, 1, 1, 0.5)
	sol.add_child(brillo)


# ---------------------------------------------------------------- relieve
func _montanas() -> void:
	_usar("lejano")
	_picos(Color("c6ddf4"), Color("f8fbff"), 500.0, 0.0, 1.25)
	_usar("medio")
	_picos(Color("a9c8e8"), Color("ffffff"), 545.0, 2.3, 0.95)


func _dunas() -> void:
	_usar("lejano")
	_capa(352.0, 120.0, 0.0026, 0.013, Color("e9c489"), 0.0, Color("ffeec2"))
	_usar("medio")
	_usar("cercano")
	_capa(468.0, 92.0, 0.0034, 0.017, Color("dca75f"), 1.9, Color("f8d79c"))
	_capa(542.0, 62.0, 0.0042, 0.021, Color("c88b45"), 3.6, Color("eec184"))


func _picos(color: Color, color_nieve: Color, base_y: float, fase: float,
		escala: float) -> void:
	var ancho_capa := ancho * _factor
	var x := -900.0
	while x < ancho_capa + 900.0:
		var ancho_pico := _rng.randf_range(300.0, 520.0) * escala
		var altura := _rng.randf_range(150.0, 330.0) * escala
		var centro := x + ancho_pico * 0.5
		var cuerpo := Polygon2D.new()
		cuerpo.polygon = PackedVector2Array([
			Vector2(centro - ancho_pico * 0.5, base_y),
			Vector2(centro, base_y - altura),
			Vector2(centro + ancho_pico * 0.5, base_y),
		])
		cuerpo.color = color
		_destino.add_child(cuerpo)

		var nieve := Polygon2D.new()
		var h_nieve := altura * 0.38
		var w_nieve := ancho_pico * 0.19
		nieve.polygon = PackedVector2Array([
			Vector2(centro - w_nieve, base_y - altura + h_nieve),
			Vector2(centro, base_y - altura),
			Vector2(centro + w_nieve, base_y - altura + h_nieve),
			Vector2(centro + w_nieve * 0.4, base_y - altura + h_nieve * 0.82),
			Vector2(centro - w_nieve * 0.5, base_y - altura + h_nieve * 0.92),
		])
		nieve.color = color_nieve
		_destino.add_child(nieve)
		x += ancho_pico * 0.68 + 30.0


func _capa(base_y: float, amplitud: float, frec_a: float, frec_b: float,
		color: Color, fase: float, brillo: Color = Color(0, 0, 0, 0)) -> void:
	var puntos := PackedVector2Array()
	puntos.append(Vector2(-600.0, 1400.0))
	var ancho_capa := ancho * _factor
	var x := -900.0
	while x <= ancho_capa + 900.0:
		var y := base_y
		y -= sin(x * frec_a + fase) * amplitud
		y -= sin(x * frec_b + fase * 1.7) * amplitud * 0.35
		puntos.append(Vector2(x, y))
		x += 26.0
	puntos.append(Vector2(ancho + 600.0, 1400.0))

	var capa := Polygon2D.new()
	capa.polygon = puntos
	capa.color = color
	_destino.add_child(capa)

	if brillo.a > 0.0:
		var cresta := Line2D.new()
		var crestas := PackedVector2Array()
		for i in range(1, puntos.size() - 1):
			crestas.append(puntos[i])
		cresta.points = crestas
		cresta.width = 2.5
		cresta.default_color = Color(brillo.r, brillo.g, brillo.b, 0.6)
		cresta.joint_mode = Line2D.LINE_JOINT_ROUND
		_destino.add_child(cresta)


func _nubes(cantidad: int, opacidad: float) -> void:
	var textura: Texture2D = load("res://recursos/sprites/nube.svg")
	if textura == null:
		return
	for i in range(cantidad):
		var nube := Sprite2D.new()
		nube.name = "NubeFondo%d" % i
		nube.texture = textura
		var escala := _rng.randf_range(0.8, 1.5)
		nube.scale = Vector2(escala, escala)
		nube.position = Vector2(_rng.randf_range(150.0, ancho - 150.0),
				_rng.randf_range(-160.0, 140.0))
		nube.modulate = Color(1, 1, 1, opacidad)
		add_child(nube)


func _circulo(radio: float, lados: int) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(lados):
		var angulo := TAU * float(i) / float(lados)
		puntos.append(Vector2(cos(angulo), sin(angulo)) * radio)
	return puntos
