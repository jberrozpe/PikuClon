extends CharacterBody2D

@export var limite_izq: float = 200.0
@export var limite_der: float = 1080.0

var vida_maxima: int = 3
var vida: int = 3
var direccion: float = -1.0
var _invulnerable: float = 0.0
var _derrotado: bool = false
var _temporizador_salto: float = 2.0

@onready var visual: Sprite2D = $Visual
@onready var zona_cabeza: Area2D = $ZonaCabeza
@onready var zona_cuerpo: Area2D = $ZonaCuerpo
@onready var sonido_golpe: AudioStreamPlayer2D = $SonidoGolpe
@onready var sonido_derrota: AudioStreamPlayer2D = $SonidoDerrota
@onready var barra_vida: ColorRect = get_node_or_null("../HUDJefe/Fondo/Relleno")


func _ready() -> void:
	zona_cabeza.body_entered.connect(_on_cabeza_entered)
	zona_cuerpo.body_entered.connect(_on_cuerpo_entered)
	_actualizar_barra()


func _physics_process(delta: float) -> void:
	if _derrotado:
		visual.rotation += 12.0 * delta
		visual.scale = visual.scale.lerp(Vector2(0.15, 0.15), 3.0 * delta)
		return

	if _invulnerable > 0.0:
		_invulnerable -= delta
		visual.modulate = Color(1.0, 0.35, 0.35, 1.0) if int(_invulnerable * 16.0) % 2 == 0 else Color.WHITE
	else:
		visual.modulate = Color.WHITE

	if not is_on_floor():
		velocity.y += 1300.0 * delta

	var velocidad_base := 150.0 + (vida_maxima - vida) * 75.0
	velocity.x = direccion * velocidad_base

	if global_position.x <= limite_izq:
		direccion = 1.0
	elif global_position.x >= limite_der:
		direccion = -1.0

	_temporizador_salto -= delta
	if _temporizador_salto <= 0.0 and is_on_floor():
		velocity.y = -460.0
		_temporizador_salto = 2.4 - (vida_maxima - vida) * 0.45

	move_and_slide()


func _on_cabeza_entered(body: Node2D) -> void:
	if _derrotado or _invulnerable > 0.0:
		return
	if body is CharacterBody2D and (body as CharacterBody2D).velocity.y > 0.0:
		(body as CharacterBody2D).velocity.y = -520.0
		_recibir_dano()


func _on_cuerpo_entered(body: Node2D) -> void:
	if _derrotado:
		return
	if body is RigidBody2D and _invulnerable <= 0.0:
		if (body as RigidBody2D).linear_velocity.length() > 90.0:
			_recibir_dano()
			return
	if body is CharacterBody2D:
		var jugador := body as CharacterBody2D
		var empuje := signf(jugador.global_position.x - global_position.x)
		if empuje == 0.0:
			empuje = direccion
		jugador.velocity = Vector2(empuje * 340.0, -300.0)


func _recibir_dano() -> void:
	vida -= 1
	_invulnerable = 1.0
	_actualizar_barra()
	if sonido_golpe:
		sonido_golpe.play()

	if vida <= 0:
		_derrotado = true
		if sonido_derrota:
			sonido_derrota.play()
		GameState.derrotar_boss()
		await get_tree().create_timer(1.6).timeout
		GameState.ir_a_escena("res://escenas/fiesta_final.tscn", "")


func _actualizar_barra() -> void:
	if barra_vida != null:
		barra_vida.size.x = 294.0 * maxf(0.0, float(vida) / float(vida_maxima))
