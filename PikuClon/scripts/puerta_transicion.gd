extends Area2D
## Portal mágico de cambio de escena.
##
## Construye su propio aspecto (núcleo luminoso, anillos de aura giratorios,
## chispas en órbita y base de piedra) en lugar de ser una caja negra.
## Mantiene la API del portal antiguo: escena_destino,
## punto_aparicion_destino, requerir_tecla y texto_indicador.

@export_file("*.tscn") var escena_destino: String = ""
@export var punto_aparicion_destino: String = ""
@export var requerir_tecla: bool = false
@export var texto_indicador: String = "[E] Entrar"
@export var color_aura: Color = Color("9b5cff")
@export var color_secundario: Color = Color("4fd6ff")
@export var requiere_bandera: String = ""   # variable de GameState que lo desbloquea

const CENTRO_Y := -88.0

var _jugador_dentro: bool = false
var _puede_activar: bool = false
var _activando: bool = false
var _bloqueado: bool = false
var _tiempo: float = 0.0

var _aura: Node2D
var _aura_interior: Node2D
var _nucleo: Polygon2D
var _halo: Polygon2D
var _chispas: Array[Polygon2D] = []
var _base: Polygon2D

@onready var indicador: Label = $Indicador
@onready var sonido: AudioStreamPlayer2D = get_node_or_null("SonidoPortal")


func _ready() -> void:
	indicador.text = texto_indicador
	indicador.visible = false
	_construir_portal()
	_bloqueado = not _bandera_ok()
	if _bloqueado:
		_mostrar_bloqueado()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	await get_tree().create_timer(0.35).timeout
	_puede_activar = true


func _process(delta: float) -> void:
	_tiempo += delta
	if _aura == null:
		return

	if _bloqueado and _bandera_ok():
		_desbloquear()

	_aura.rotation += 1.1 * delta
	_aura_interior.rotation -= 1.9 * delta

	var pulso := 0.5 + 0.5 * sin(_tiempo * 2.4)
	_nucleo.modulate.a = 0.72 + 0.2 * pulso
	_nucleo.scale = Vector2.ONE + Vector2(0.05, 0.03) * pulso
	_halo.modulate.a = 0.16 + 0.1 * pulso
	_halo.scale = Vector2.ONE + Vector2(0.08, 0.05) * pulso

	for i in range(_chispas.size()):
		var chispa := _chispas[i]
		var angulo := _tiempo * (1.6 + i * 0.22) + TAU * float(i) / float(_chispas.size())
		chispa.position = Vector2(cos(angulo) * 48.0, sin(angulo) * 80.0 + CENTRO_Y)
		chispa.modulate.a = 0.5 + 0.5 * sin(_tiempo * 3.0 + i)


func _construir_portal() -> void:
	_halo = Polygon2D.new()
	_halo.name = "Halo"
	_halo.polygon = _oval(60.0, 96.0)
	_halo.color = color_aura
	_halo.modulate.a = 0.2
	_halo.position.y = CENTRO_Y
	_halo.z_index = 2
	add_child(_halo)

	_nucleo = Polygon2D.new()
	_nucleo.name = "Nucleo"
	_nucleo.polygon = _oval(44.0, 80.0)
	_nucleo.color = color_secundario.lerp(Color.WHITE, 0.35)
	_nucleo.position.y = CENTRO_Y
	_nucleo.z_index = 3
	add_child(_nucleo)

	var nucleo_interior := Polygon2D.new()
	nucleo_interior.name = "NucleoInterior"
	nucleo_interior.polygon = _oval(24.0, 48.0)
	nucleo_interior.color = Color(1, 1, 1, 0.55)
	nucleo_interior.position.y = CENTRO_Y
	nucleo_interior.z_index = 4
	add_child(nucleo_interior)

	var borde := Line2D.new()
	borde.name = "Borde"
	borde.width = 3.5
	borde.default_color = Color(1, 1, 1, 0.85)
	borde.closed = true
	for i in range(32):
		var angulo := TAU * float(i) / 32.0
		borde.add_point(Vector2(cos(angulo) * 44.0, sin(angulo) * 80.0))
	borde.position.y = CENTRO_Y
	borde.z_index = 5
	add_child(borde)

	_aura = Node2D.new()
	_aura.name = "AuraExterior"
	_aura.position.y = CENTRO_Y
	_aura.z_index = 6
	add_child(_aura)
	_crear_arcos(_aura, 66.0, 102.0, color_aura, 5.0, 7)

	_aura_interior = Node2D.new()
	_aura_interior.name = "AuraInterior"
	_aura_interior.position.y = CENTRO_Y
	_aura_interior.z_index = 7
	add_child(_aura_interior)
	_crear_arcos(_aura_interior, 52.0, 88.0, color_secundario, 3.5, 5)

	for i in range(6):
		var chispa := Polygon2D.new()
		chispa.name = "Chispa%d" % i
		chispa.polygon = PackedVector2Array([
			Vector2(0, -4), Vector2(2.2, 0), Vector2(0, 4), Vector2(-2.2, 0),
		])
		chispa.color = color_secundario.lerp(Color.WHITE, 0.4)
		chispa.z_index = 8
		add_child(chispa)
		_chispas.append(chispa)

	var base := Polygon2D.new()
	base.name = "Base"
	base.polygon = PackedVector2Array([
		Vector2(-36, 0), Vector2(36, 0), Vector2(27, 13), Vector2(-27, 13),
	])
	base.color = Color("6b6f7d")
	base.z_index = 1
	add_child(base)
	_base = base


func _oval(radio_x: float, radio_y: float) -> PackedVector2Array:
	var puntos := PackedVector2Array()
	for i in range(32):
		var angulo := TAU * float(i) / 32.0
		puntos.append(Vector2(cos(angulo) * radio_x, sin(angulo) * radio_y))
	return puntos


func _crear_arcos(
		padre: Node2D,
		radio_x: float,
		radio_y: float,
		color: Color,
		grosor: float,
		segmentos: int
) -> void:
	for tramo in range(segmentos):
		var arco := Line2D.new()
		arco.width = grosor
		arco.default_color = color
		arco.joint_mode = Line2D.LINE_JOINT_ROUND
		arco.begin_cap_mode = Line2D.LINE_CAP_ROUND
		arco.end_cap_mode = Line2D.LINE_CAP_ROUND
		var inicio := TAU * float(tramo) / float(segmentos)
		var fin := inicio + TAU / float(segmentos) * 0.62
		for paso in range(7):
			var t := lerpf(inicio, fin, float(paso) / 6.0)
			arco.add_point(Vector2(cos(t) * radio_x, sin(t) * radio_y))
		padre.add_child(arco)


func _bandera_ok() -> bool:
	return requiere_bandera.is_empty() or bool(GameState.get(requiere_bandera))


func _mostrar_bloqueado() -> void:
	# Mientras está sellado, el portal queda oculto tras la puerta de piedra.
	indicador.text = "Sellado · usa el grito"
	for nodo in [_halo, _nucleo, _aura, _aura_interior, _base]:
		if nodo is CanvasItem:
			(nodo as CanvasItem).visible = false
	for chispa in _chispas:
		chispa.visible = false


func _desbloquear() -> void:
	_bloqueado = false
	indicador.text = texto_indicador
	for nodo in [_halo, _nucleo, _aura, _aura_interior, _base]:
		if nodo is CanvasItem:
			(nodo as CanvasItem).visible = true
	for chispa in _chispas:
		chispa.visible = true
	Efectos.anillo(global_position + Vector2(0, CENTRO_Y), color_secundario, 140.0, 6.0, 0.7)
	Efectos.destello(global_position + Vector2(0, CENTRO_Y), Color(1, 1, 1, 0.9), 44.0)


func _unhandled_input(event: InputEvent) -> void:
	if not requerir_tecla or not _jugador_dentro or not _puede_activar:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_activar()


func _on_body_entered(body: Node2D) -> void:
	if not _puede_activar or _activando or not (body is CharacterBody2D):
		return
	_jugador_dentro = true
	if _bloqueado:
		indicador.text = "Sellado · usa el grito"
		indicador.visible = true
		return
	if requerir_tecla:
		indicador.visible = true
	else:
		_activar()


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_dentro = false
		indicador.visible = false
		if _bloqueado:
			indicador.text = "Sellado · usa el grito"


func _activar() -> void:
	if escena_destino.is_empty() or _activando or _bloqueado:
		return
	_activando = true
	_puede_activar = false
	indicador.visible = false
	if sonido != null:
		sonido.play()

	var tw := create_tween()
	tw.set_parallel(true)
	tw.tween_property(self, "scale", Vector2(1.25, 1.25), 0.35).set_ease(Tween.EASE_OUT)
	tw.tween_property(_nucleo, "modulate", Color(1, 1, 1, 1), 0.3)
	await tw.finished
	GameState.ir_a_escena(escena_destino, punto_aparicion_destino)
