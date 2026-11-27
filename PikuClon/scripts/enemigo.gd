extends CharacterBody2D
## Enemigo sencillo: patrulla, persigue al jugador y puede congelarse o
## quedar aturdido por el grito gutural.

@export var velocidad: float = 62.0
@export var rango_persecucion: float = 320.0
@export var fuerza_empuje: float = 340.0

var _dir: float = -1.0
var _congelado: float = 0.0
var _aturdido: float = 0.0

@onready var visual: Node2D = $Visual
@onready var bloque_hielo: Node2D = get_node_or_null("BloqueHielo")


func _ready() -> void:
	add_to_group("enemigo")
	if bloque_hielo != null:
		bloque_hielo.visible = false


func _physics_process(delta: float) -> void:
	if _congelado > 0.0:
		_congelado -= delta
		velocity = Vector2.ZERO
		if _congelado <= 0.0:
			_descongelar()
		return

	if _aturdido > 0.0:
		_aturdido -= delta
		velocity = velocity.move_toward(Vector2.ZERO, 900.0 * delta)
		move_and_slide()
		return

	var jugador := get_tree().get_first_node_in_group("jugador") as Node2D
	if jugador != null:
		var distancia := jugador.global_position - global_position
		if distancia.length() < rango_persecucion:
			_dir = signf(distancia.x) if absf(distancia.x) > 6.0 else _dir

	velocity.x = _dir * velocidad
	if not is_on_floor():
		velocity.y += 1500.0 * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	if is_on_wall():
		_dir *= -1.0
	if visual != null:
		visual.scale.x = _dir

	_comprobar_contacto(jugador)


func _comprobar_contacto(jugador: Node2D) -> void:
	if jugador == null:
		return
	var d := jugador.global_position - global_position
	if absf(d.x) > 40.0 or absf(d.y) > 54.0:
		return
	if jugador is CharacterBody2D:
		if bool(jugador.get("escudo_activo")):
			# El escudo repele al bicho.
			velocity = Vector2(-signf(d.x) * 320.0, -260.0)
			_aturdido = 0.6
			return
		var cuerpo := jugador as CharacterBody2D
		cuerpo.velocity = Vector2(signf(d.x) * fuerza_empuje, -230.0)


func congelar(segundos: float) -> void:
	if _congelado > 0.0:
		_congelado = maxf(_congelado, segundos)
		return
	_congelado = segundos
	velocity = Vector2.ZERO
	if bloque_hielo != null:
		bloque_hielo.visible = true
		bloque_hielo.modulate.a = 1.0
	if visual != null:
		visual.modulate = Color(0.65, 0.9, 1.0, 1.0)
	Efectos.destello(global_position, Color(0.8, 0.96, 1.0), 34.0)
	Efectos.chispas(global_position, Color(0.85, 0.97, 1.0), 8, 40.0, 0.4)
	GameState.congelar_yeti()


func _descongelar() -> void:
	_congelado = 0.0
	if bloque_hielo != null:
		bloque_hielo.visible = false
	if visual != null:
		visual.modulate = Color.WHITE
	Efectos.trozos(global_position, Color(0.8, 0.95, 1.0), 6, 60.0)


func recibir_grito(direccion: float) -> void:
	if _congelado > 0.0:
		return
	_aturdido = 0.9
	velocity = Vector2(direccion * 320.0, -220.0)
	if visual != null:
		visual.modulate = Color(1.0, 0.85, 0.6, 1.0)
		var tw := create_tween()
		tw.tween_interval(0.9)
		tw.tween_callback(func() -> void:
			if visual != null:
				visual.modulate = Color.WHITE
		)
