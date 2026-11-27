extends Path2D
## Rizo del camino: un loop completo que lanza al jugador en bola hasta la
## plataforma alta. La curva y la pista se generan por código para poder
## ajustar el trazado y el estilo sin tocar el .tscn.

@export var velocidad_rizo: float = 540.0
@export var velocidad_salida: Vector2 = Vector2(380.0, -560.0)
@export var radio: float = 95.0
@export var ancho_pista: float = 34.0
@export var vueltas: float = 1.25

var _jugador_activo: CharacterBody2D = null
var _enfriamiento: float = 0.0
var _centro: Vector2 = Vector2.ZERO

@onready var seguidor: PathFollow2D = $Seguidor
@onready var pista_visual: Line2D = $PistaVisual
@onready var entrada: Area2D = $EntradaRizo


func _ready() -> void:
	_centro = Vector2(0.0, -radio)
	_construir_curva()
	_construir_pista()
	entrada.position = Vector2.ZERO
	entrada.body_entered.connect(_on_entrada_body_entered)


func _physics_process(delta: float) -> void:
	if _enfriamiento > 0.0:
		_enfriamiento -= delta

	if _jugador_activo != null and is_instance_valid(_jugador_activo):
		seguidor.progress += velocidad_rizo * delta
		_jugador_activo.global_position = seguidor.global_position
		_jugador_activo.cuerpo_visual.rotation += 12.0 * delta

		if seguidor.progress_ratio >= 0.99:
			_jugador_activo._en_rizo = false
			_jugador_activo.velocity = velocidad_salida
			_jugador_activo = null
			_enfriamiento = 0.6


func _construir_curva() -> void:
	var nueva := Curve2D.new()
	var total := TAU * vueltas
	var pasos := 72
	var inicio := PI / 2.0
	for i in range(pasos + 1):
		var angulo: float = inicio - total * float(i) / float(pasos)
		nueva.add_point(_centro + Vector2(cos(angulo), sin(angulo)) * radio)
	curve = nueva


func _construir_pista() -> void:
	if pista_visual != null:
		pista_visual.visible = false

	var puntos: PackedVector2Array = curve.get_baked_points()

	# Sombra y base de madera para que el rizo se apoye en el suelo.
	var sombra := Polygon2D.new()
	var elipse := PackedVector2Array()
	for i in range(20):
		var a := TAU * float(i) / 20.0
		elipse.append(Vector2(cos(a) * 118.0, 6.0 + sin(a) * 14.0))
	sombra.polygon = elipse
	sombra.color = Color(0.05, 0.09, 0.05, 0.16)
	add_child(sombra)

	var base := Polygon2D.new()
	base.polygon = PackedVector2Array([
		Vector2(-104, -2), Vector2(104, -2), Vector2(96, 8), Vector2(-96, 8),
	])
	base.color = Color("8a5a34")
	add_child(base)

	# Pista: contorno oscuro, madera y línea de brillo central.
	_linea(puntos, ancho_pista + 7.0, Color("1d1e26"))
	_linea(puntos, ancho_pista, Color("c9864b"))
	_linea(puntos, 3.5, Color("f2c46b"))

	# Flechas de sentido (estilo Pikuniku).
	for i in range(8):
		var indice := int(float(i) / 8.0 * float(puntos.size() - 2))
		var punto := puntos[indice]
		var siguiente := puntos[mini(indice + 2, puntos.size() - 1)]
		var direccion := (siguiente - punto).normalized()
		var flecha := Polygon2D.new()
		flecha.polygon = PackedVector2Array([
			Vector2(0, 0), Vector2(-15, -9), Vector2(-10, 0), Vector2(-15, 9),
		])
		flecha.color = Color(1, 0.96, 0.85, 0.9)
		flecha.position = punto
		flecha.rotation = direccion.angle()
		flecha.scale = Vector2(0.85, 0.85)
		add_child(flecha)


func _linea(puntos: PackedVector2Array, grosor: float, color: Color) -> void:
	var linea := Line2D.new()
	linea.points = puntos
	linea.width = grosor
	linea.default_color = color
	linea.joint_mode = Line2D.LINE_JOINT_ROUND
	linea.begin_cap_mode = Line2D.LINE_CAP_ROUND
	linea.end_cap_mode = Line2D.LINE_CAP_ROUND
	add_child(linea)


func _on_entrada_body_entered(body: Node2D) -> void:
	if _jugador_activo != null or _enfriamiento > 0.0:
		return
	if body is CharacterBody2D and body.get("en_bolita") == true and body.velocity.x > 120.0:
		_jugador_activo = body as CharacterBody2D
		_jugador_activo._en_rizo = true
		seguidor.progress = 0.0
