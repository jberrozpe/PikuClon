extends Node2D

const COLORES_FUEGOS := [
	Color(0.901961, 0.223529, 0.27451, 1),
	Color(1, 0.819608, 0.25098, 1),
	Color(0.180392, 0.768627, 0.713725, 1),
	Color(0.247059, 0.54902, 0.878431, 1),
	Color(0.945098, 0.356863, 0.709804, 1),
]

var _tiempo: float = 0.0
var _tiempo_cohete: float = 0.0
var _particulas: Array[Dictionary] = []
var _pos_base_invitados: Dictionary = {}

@onready var invitados: Node2D = $InvitadosFiesta
@onready var lluvia_confetti: CPUParticles2D = $LluviaConfetti
@onready var fuegos: Node2D = $FuegosArtificiales
@onready var cartel_gracias: CanvasLayer = $CartelGracias
@onready var btn_explorar: Button = $CartelGracias/Panel/BtnExplorar
@onready var sonido_cohete: AudioStreamPlayer = $SonidoCohete


func _ready() -> void:
	var activo := GameState.juego_completado
	visible = activo
	lluvia_confetti.emitting = activo
	cartel_gracias.visible = activo

	if not activo:
		set_process(false)
		return

	btn_explorar.pressed.connect(func() -> void: cartel_gracias.visible = false)
	for hijo in invitados.get_children():
		if hijo is Node2D:
			_pos_base_invitados[hijo.name] = (hijo as Node2D).position.y
	_lanzar_fuego()


func _process(delta: float) -> void:
	_tiempo += delta
	_tiempo_cohete += delta
	if _tiempo_cohete >= 1.1:
		_tiempo_cohete = 0.0
		_lanzar_fuego()

	var idx := 0
	for hijo in invitados.get_children():
		if hijo is Node2D:
			var base_y: float = _pos_base_invitados.get(hijo.name, 530.0)
			(hijo as Node2D).position.y = base_y - absf(sin(_tiempo * 5.2 + idx * 0.8)) * 22.0
			idx += 1

	var restantes: Array[Dictionary] = []
	for p in _particulas:
		var nodo: Polygon2D = p["nodo"]
		p["vida"] -= delta
		if p["vida"] > 0.0:
			p["vel"].y += 220.0 * delta
			nodo.position += p["vel"] * delta
			nodo.modulate.a = clampf(p["vida"] / 1.1, 0.0, 1.0)
			restantes.append(p)
		else:
			nodo.queue_free()
	_particulas = restantes


func _lanzar_fuego() -> void:
	var centro := Vector2(randf_range(350.0, 2050.0), randf_range(90.0, 240.0))
	var color: Color = COLORES_FUEGOS[randi() % COLORES_FUEGOS.size()]
	if sonido_cohete:
		sonido_cohete.play()

	for i in range(12):
		var angulo := (TAU / 12.0) * i + randf_range(-0.15, 0.15)
		var vel := Vector2(cos(angulo), sin(angulo)) * randf_range(80.0, 170.0)
		var chispa := Polygon2D.new()
		chispa.polygon = PackedVector2Array([-4, -4, 4, -4, 4, 4, -4, 4])
		chispa.color = color
		chispa.position = centro
		fuegos.add_child(chispa)
		_particulas.append({
			"nodo": chispa,
			"vel": vel,
			"vida": randf_range(0.8, 1.2),
		})
