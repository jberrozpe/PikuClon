extends CharacterBody2D

enum Estado { ESPERANDO, EMBISTIENDO, ATURDIDO, DERROTADO }

@export var limite_izq: float = 110.0
@export var limite_der: float = 1170.0
@export var velocidad_embestida: float = 460.0

var vida_maxima: int = 3
var vida: int = 3
var estado: Estado = Estado.ESPERANDO
var _direccion: float = -1.0
var _temporizador: float = 1.2
var _tiempo: float = 0.0

@onready var visual: Sprite2D = $Visual
@onready var estrellas_mareo: Node2D = $EstrellasMareo
@onready var zona_golpe: Area2D = $ZonaGolpe
@onready var particulas_confetti: CPUParticles2D = $ParticulasConfetti
@onready var sonido_golpe: AudioStreamPlayer2D = $SonidoGolpe
@onready var sonido_choque: AudioStreamPlayer2D = $SonidoChoque
@onready var barra_vida: ColorRect = get_node_or_null("../HUDJefe/Fondo/Relleno")
@onready var etiqueta_estado: Label = get_node_or_null("../HUDJefe/Estado")


func _ready() -> void:
	estrellas_mareo.visible = false
	zona_golpe.body_entered.connect(_on_zona_golpe_entered)
	_actualizar_hud()


func _physics_process(delta: float) -> void:
	_tiempo += delta
	if not is_on_floor():
		velocity.y += 1400.0 * delta

	match estado:
		Estado.ESPERANDO:
			velocity.x = 0.0
			visual.scale = visual.scale.lerp(Vector2(1.08, 0.92), 8.0 * delta)
			_temporizador -= delta
			if _temporizador <= 0.0:
				_iniciar_embestida()
		Estado.EMBISTIENDO:
			visual.scale = visual.scale.lerp(Vector2.ONE, 10.0 * delta)
			var extra := (vida_maxima - vida) * 65.0
			velocity.x = _direccion * (velocidad_embestida + extra)
			if global_position.x <= limite_izq or global_position.x >= limite_der or is_on_wall():
				_chocar_y_aturdir()
		Estado.ATURDIDO:
			velocity.x = 0.0
			estrellas_mareo.visible = true
			estrellas_mareo.rotation = _tiempo * 4.5
			visual.rotation = sin(_tiempo * 14.0) * 0.1
			_temporizador -= delta
			if _temporizador <= 0.0:
				estrellas_mareo.visible = false
				visual.rotation = 0.0
				estado = Estado.ESPERANDO
				_temporizador = 1.0
				_actualizar_hud()
		Estado.DERROTADO:
			velocity.x = 0.0
			visual.rotation += 14.0 * delta
			visual.scale = visual.scale.lerp(Vector2(0.1, 0.1), 3.0 * delta)

	move_and_slide()


func _iniciar_embestida() -> void:
	var jugador := get_parent().get_node_or_null("Jugador")
	if jugador is Node2D:
		_direccion = signf((jugador as Node2D).global_position.x - global_position.x)
		if _direccion == 0.0:
			_direccion = -1.0
	estado = Estado.EMBISTIENDO
	_actualizar_hud()


func _chocar_y_aturdir() -> void:
	global_position.x = clampf(global_position.x, limite_izq + 12.0, limite_der - 12.0)
	estado = Estado.ATURDIDO
	_temporizador = 3.8
	if sonido_choque:
		sonido_choque.play()
	_actualizar_hud()


func _on_zona_golpe_entered(body: Node2D) -> void:
	if estado == Estado.DERROTADO:
		return

	if body is RigidBody2D and estado == Estado.ATURDIDO:
		body.queue_free()
		_recibir_dano_confetti()
		return

	if body is CharacterBody2D and estado == Estado.EMBISTIENDO:
		var jugador := body as CharacterBody2D
		var empuje := signf(jugador.global_position.x - global_position.x)
		if empuje == 0.0:
			empuje = _direccion
		jugador.velocity = Vector2(empuje * 380.0, -320.0)


func _recibir_dano_confetti() -> void:
	vida -= 1
	estrellas_mareo.visible = false
	visual.rotation = 0.0
	particulas_confetti.restart()
	particulas_confetti.emitting = true
	if sonido_golpe:
		sonido_golpe.play()

	if vida <= 0:
		estado = Estado.DERROTADO
		_actualizar_hud()
		GameState.derrotar_boss()
		await get_tree().create_timer(1.6).timeout
		GameState.ir_a_escena("res://escenas/pueblo.tscn", "")
	else:
		estado = Estado.ESPERANDO
		_temporizador = 1.0
		_actualizar_hud()


func _actualizar_hud() -> void:
	if barra_vida != null:
		barra_vida.size.x = 294.0 * maxf(0.0, float(vida) / float(vida_maxima))
	if etiqueta_estado != null:
		match estado:
			Estado.ESPERANDO:
				etiqueta_estado.text = "DON CUADRADO se prepara para embestir..."
			Estado.EMBISTIENDO:
				etiqueta_estado.text = "¡CUIDADO! ¡Esquiva su embestida hacia la pared!"
			Estado.ATURDIDO:
				etiqueta_estado.text = "¡MAREADO! ¡Patéale un objeto de confetti (E / Espacio)!"
			Estado.DERROTADO:
				etiqueta_estado.text = "¡VICTORIA! ¡Volviendo al Pueblo para la Fiesta!"
