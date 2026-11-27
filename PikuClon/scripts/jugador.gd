extends CharacterBody2D

@export_group("Movimiento")
@export var velocidad_maxima: float = 290.0
@export var velocidad_rodar: float = 440.0
@export var aceleracion_suelo: float = 1900.0
@export var friccion_suelo: float = 1700.0
@export var friccion_rodar: float = 190.0
@export var aceleracion_aire: float = 1200.0
@export var friccion_aire: float = 350.0

@export_group("Salto y Gravedad")
@export var velocidad_salto: float = -560.0
@export var gravedad_subida: float = 1200.0
@export var gravedad_bajada: float = 1650.0
@export var coyote_time: float = 0.10

@export_group("Interaccion Fisica")
@export var fuerza_empuje: float = 60.0
@export var fuerza_patada_x: float = 520.0
@export var fuerza_patada_y: float = -260.0
@export var enfriamiento_patada: float = 0.32

@export_group("Poderes")
@export var radio_grito: float = 320.0
@export var radio_hielo: float = 280.0
@export var enfriamiento_grito: float = 2.2
@export var enfriamiento_hielo: float = 1.4
@export var enfriamiento_talisman: float = 12.0
@export var duracion_escudo: float = 6.0

@export_group("Movimientos especiales")
@export var velocidad_doble_salto: float = -470.0
@export var impulso_patada_voladora: float = 780.0
@export var enfriamiento_voladora: float = 0.55

@export_group("Camara")
@export var camara_limite_izquierdo: int = 0
@export var camara_limite_superior: int = 0
@export var camara_limite_derecho: int = 1152
@export var camara_limite_inferior: int = 648
@export var camara_suavizado: float = 7.0

@export_group("Nivel")
@export var nombre_zona: String = "Pueblo"

var direccion_mirada: float = 1.0
var tiempo_caminar: float = 0.0
var temporizador_patada: float = 0.0
var temporizador_anim_patada: float = 0.0
var temporizador_coyote: float = 0.0
var tiempo_aterrizaje: float = 0.0
var estaba_en_suelo: bool = false
var en_bolita: bool = false
var _en_rizo: bool = false
var _saltos_usados: int = 0
var _giro_pendiente: float = 0.0
var _estela_restante: float = 0.0
var _invulnerable: float = 0.0
var _sonido_doble_salto: AudioStreamPlayer
var _sonido_patada_voladora: AudioStreamPlayer
var _sonido_grito: AudioStreamPlayer
var _sonido_hielo: AudioStreamPlayer
var _sonido_escudo: AudioStreamPlayer
var _cd_grito: float = 0.0
var _cd_hielo: float = 0.0
var _cd_talisman: float = 0.0
var _escudo_restante: float = 0.0
var escudo_activo: bool = false
var _sacudida: float = 0.0
var _camara: Camera2D
var _burbuja: Polygon2D

@onready var colision_cuerpo: CollisionShape2D = $CollisionShape2D
@onready var cuerpo_visual: Node2D = $CuerpoVisual
@onready var torso: Node2D = $CuerpoVisual/Torso
@onready var pierna_izq: Line2D = $CuerpoVisual/PiernaIzq
@onready var pierna_der: Line2D = $CuerpoVisual/PiernaDer
@onready var ojos: Node2D = $CuerpoVisual/Ojos
@onready var zona_patada: Area2D = $ZonaPatada
@onready var efecto_patada: Polygon2D = $ZonaPatada/EfectoPatada
@onready var sonido_salto: AudioStreamPlayer = get_node_or_null("SonidoSalto")
@onready var sonido_patada: AudioStreamPlayer = get_node_or_null("SonidoPatada")


const TEXTURAS_VESTUARIO := {
	"sombrero": {
		"copa": "res://recursos/vestuario/sombrero_copa.svg",
		"helice": "res://recursos/vestuario/sombrero_helice.svg",
		"corona": "res://recursos/vestuario/sombrero_corona.svg",
		"tiroles": "res://recursos/vestuario/sombrero_tiroles.svg",
		"bombin": "res://recursos/vestuario/sombrero_bombin.svg",
		"ninja": "res://recursos/vestuario/banda_ninja.svg",
	},
	"gafas": {
		"sol": "res://recursos/vestuario/gafas_sol.svg",
		"estrella": "res://recursos/vestuario/gafas_estrella.svg",
	},
	"guantes": {
		"blancos": "res://recursos/vestuario/guantes_blancos.svg",
	},
	"corbata": {
		"corbata": "res://recursos/vestuario/corbata.svg",
	},
	"camisa": {
		"rayas": "res://recursos/vestuario/camisa_rayas.svg",
	},
}

var _capas_vestuario: Dictionary = {}


func _ready() -> void:
	floor_max_angle = deg_to_rad(65.0)
	floor_snap_length = 12.0
	_configurar_controles()
	_crear_sonidos_nuevos()
	add_to_group("jugador")
	efecto_patada.visible = false
	_aplicar_punto_aparicion()
	_configurar_camara()
	_configurar_vestuario()
	GameState.zona_actual = nombre_zona
	GameState.mision_actualizada.emit()
	GameState.vestuario_cambiado.connect(_actualizar_vestuario)
	GameState.vestuario_cambiado.connect(_actualizar_lampara)
	_crear_lampara()
	_actualizar_vestuario()
	_actualizar_lampara()


var _objeto_mano: Sprite2D
var _luz_mano: Sprite2D
const TEXTURAS_MANO := {
	"lampara": "res://recursos/sprites/lampara_maravillas.svg",
	"antorcha": "res://recursos/sprites/antorcha.svg",
}


func _crear_lampara() -> void:
	_objeto_mano = Sprite2D.new()
	_objeto_mano.name = "ObjetoMano"
	_objeto_mano.scale = Vector2(0.32, 0.32)
	_objeto_mano.position = Vector2(0, -2)
	_objeto_mano.visible = false
	add_child(_objeto_mano)

	_luz_mano = Sprite2D.new()
	_luz_mano.name = "LuzMano"
	_luz_mano.set_script(load("res://scripts/luz_portatil.gd"))
	_luz_mano.visible = false
	add_child(_luz_mano)
	_actualizar_lampara()


func _actualizar_lampara() -> void:
	if _objeto_mano == null:
		return
	var equipado := GameState.obtener_equipado("lampara")
	var tiene := TEXTURAS_MANO.has(equipado)
	_objeto_mano.visible = tiene
	_luz_mano.visible = tiene
	if tiene:
		_objeto_mano.texture = load(TEXTURAS_MANO[equipado])
		var desfase := Vector2(direccion_mirada * 20.0, -2)
		_objeto_mano.position = desfase
		_luz_mano.position = desfase
		_luz_mano.scale = Vector2.ONE * (0.9 if equipado == "antorcha" else 0.7)


func _crear_burbuja() -> void:
	_burbuja = Polygon2D.new()
	_burbuja.name = "EscudoBurbuja"
	var puntos := PackedVector2Array()
	for i in range(28):
		var a := TAU * float(i) / 28.0
		puntos.append(Vector2(cos(a) * 48.0, sin(a) * 54.0))
	_burbuja.polygon = puntos
	_burbuja.color = Color(0.55, 0.9, 1.0, 0.3)
	_burbuja.position = Vector2(0, -8)
	_burbuja.z_index = 4
	_burbuja.visible = false
	add_child(_burbuja)


func _crear_sonidos_nuevos() -> void:
	_sonido_doble_salto = AudioStreamPlayer.new()
	_sonido_doble_salto.stream = load("res://recursos/sonidos/doble_salto.wav")
	add_child(_sonido_doble_salto)

	_sonido_patada_voladora = AudioStreamPlayer.new()
	_sonido_patada_voladora.stream = load("res://recursos/sonidos/patada_voladora.wav")
	add_child(_sonido_patada_voladora)

	_sonido_grito = AudioStreamPlayer.new()
	_sonido_grito.stream = load("res://recursos/sonidos/grito.wav")
	add_child(_sonido_grito)

	_sonido_hielo = AudioStreamPlayer.new()
	_sonido_hielo.stream = load("res://recursos/sonidos/hielo.wav")
	add_child(_sonido_hielo)

	_sonido_escudo = AudioStreamPlayer.new()
	_sonido_escudo.stream = load("res://recursos/sonidos/escudo.wav")
	add_child(_sonido_escudo)

	_crear_burbuja()


func _configurar_vestuario() -> void:
	var capa_camisa := Sprite2D.new()
	capa_camisa.name = "CapaCamisa"
	capa_camisa.position = Vector2(0.0, 5.0)
	cuerpo_visual.add_child(capa_camisa)
	cuerpo_visual.move_child(capa_camisa, torso.get_index() + 1)

	var capa_corbata := Sprite2D.new()
	capa_corbata.name = "CapaCorbata"
	capa_corbata.position = Vector2(0.0, 5.0)
	cuerpo_visual.add_child(capa_corbata)
	cuerpo_visual.move_child(capa_corbata, capa_camisa.get_index() + 1)

	var capa_guantes := Sprite2D.new()
	capa_guantes.name = "CapaGuantes"
	capa_guantes.position = Vector2(0.0, 2.0)
	cuerpo_visual.add_child(capa_guantes)

	var capa_gafas := Sprite2D.new()
	capa_gafas.name = "CapaGafas"
	capa_gafas.position = Vector2(0.0, 0.0)
	ojos.add_child(capa_gafas)

	var capa_sombrero := Sprite2D.new()
	capa_sombrero.name = "CapaSombrero"
	capa_sombrero.position = Vector2(0.0, -40.0)
	cuerpo_visual.add_child(capa_sombrero)

	_capas_vestuario = {
		"camisa": capa_camisa,
		"corbata": capa_corbata,
		"guantes": capa_guantes,
		"gafas": capa_gafas,
		"sombrero": capa_sombrero,
	}


func _actualizar_vestuario() -> void:
	for categoria in _capas_vestuario.keys():
		var sprite: Sprite2D = _capas_vestuario[categoria]
		var id_equipado := GameState.obtener_equipado(categoria)
		if id_equipado.is_empty():
			sprite.texture = null
			sprite.visible = false
		else:
			var rutas: Dictionary = TEXTURAS_VESTUARIO.get(categoria, {})
			var ruta: String = rutas.get(id_equipado, "")
			if ruta.is_empty():
				sprite.texture = null
				sprite.visible = false
			else:
				sprite.texture = load(ruta)
				sprite.visible = true


func _configurar_camara() -> void:
	var camara: Camera2D = get_node_or_null("Camera2D")
	if camara == null:
		camara = Camera2D.new()
		camara.name = "Camera2D"
		add_child(camara)
	camara.limit_left = camara_limite_izquierdo
	camara.limit_top = camara_limite_superior
	camara.limit_right = camara_limite_derecho
	camara.limit_bottom = camara_limite_inferior
	# Sin suavizado: la cámara va pegada al personaje y el paralaje no arrastra retardo.
	camara.position_smoothing_enabled = false
	camara.position_smoothing_speed = camara_suavizado
	camara.enabled = true
	_camara = camara


func _aplicar_punto_aparicion() -> void:
	if GameState.punto_aparicion.is_empty():
		return
	var escena_actual := get_tree().current_scene
	if escena_actual == null:
		return
	var marcador := escena_actual.find_child(GameState.punto_aparicion, true, false)
	if marcador is Node2D:
		global_position = (marcador as Node2D).global_position
	GameState.punto_aparicion = ""


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		get_tree().reload_current_scene()


func _physics_process(delta: float) -> void:
	if _en_rizo:
		return
	if _invulnerable > 0.0:
		_invulnerable -= delta
	if _cd_grito > 0.0:
		_cd_grito -= delta
	if _cd_hielo > 0.0:
		_cd_hielo -= delta
	if _cd_talisman > 0.0:
		_cd_talisman -= delta
	if _escudo_restante > 0.0:
		_escudo_restante -= delta
		escudo_activo = true
		_burbuja.visible = true
		_burbuja.rotation += delta * 1.6
		_burbuja.color.a = 0.3 if _escudo_restante > 1.2 else 0.3 * maxf(_escudo_restante, 0.0) / 1.2
		if _escudo_restante <= 0.0:
			_escudo_restante = 0.0
			escudo_activo = false
			_burbuja.visible = false
			Efectos.anillo(global_position, Color(0.6, 0.9, 1.0), 74.0, 4.0, 0.4)

	if _sacudida > 0.0:
		_sacudida = maxf(0.0, _sacudida - delta * 2.4)
		if _camara != null:
			_camara.offset = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _sacudida * 10.0
	elif _camara != null and _camara.offset.length() > 0.5:
		_camara.offset = _camara.offset.lerp(Vector2.ZERO, 10.0 * delta)

	if temporizador_patada > 0.0:
		temporizador_patada -= delta
	if temporizador_anim_patada > 0.0:
		temporizador_anim_patada -= delta
		if temporizador_anim_patada <= 0.0:
			efecto_patada.visible = false
			zona_patada.scale = Vector2.ONE
	if tiempo_aterrizaje > 0.0:
		tiempo_aterrizaje -= delta

	# Coyote time
	if is_on_floor():
		if not estaba_en_suelo:
			# Squash al aterrizar
			torso.scale = Vector2(1.24, 0.76)
			tiempo_aterrizaje = 0.14
			if velocity.y > 320.0:
				Efectos.chispas(global_position + Vector2(0, 26),
						Color(0.96, 0.93, 0.86), 5, 34.0, 0.3)
		temporizador_coyote = coyote_time
		_saltos_usados = 0
	else:
		temporizador_coyote -= delta
		if estaba_en_suelo and _saltos_usados == 0:
			# Se cayó de una plataforma: le queda un solo salto aéreo.
			_saltos_usados = 1
	estaba_en_suelo = is_on_floor()

	# Gravedad diferenciada para un salto juguetón
	if not is_on_floor():
		var grav := gravedad_subida if velocity.y < 0.0 else gravedad_bajada
		velocity.y += grav * delta

	# Salto con coyote time, altura variable y doble salto si lo ha aprendido
	if Input.is_action_just_pressed("saltar"):
		if temporizador_coyote > 0.0:
			_hacer_salto(false)
		elif _saltos_usados < _max_saltos():
			_hacer_salto(true)
	elif Input.is_action_just_released("saltar") and velocity.y < -120.0:
		velocity.y *= 0.52

	# Estela mientras dura la patada voladora
	if _estela_restante > 0.0:
		_estela_restante -= delta
		Efectos.estela(global_position + Vector2(-direccion_mirada * 8.0, 4.0),
				direccion_mirada, Color(0.55, 0.9, 1.0, 0.7))
		Efectos.estela(global_position + Vector2(-direccion_mirada * 8.0, -16.0),
				direccion_mirada, Color(0.85, 0.97, 1.0, 0.5), 30.0)

	# Modo bolita / rodar (S o Flecha Abajo)
	var quiere_bolita := Input.is_action_pressed("agacharse")
	if not quiere_bolita and en_bolita:
		if test_move(global_transform, Vector2(0.0, -18.0)):
			quiere_bolita = true
	en_bolita = quiere_bolita
	_actualizar_colision_bolita()

	# Movimiento lateral fluido y conservación de velocidad en rampas
	var entrada_x := Input.get_axis("mover_izquierda", "mover_derecha")
	var vel_objetivo := velocidad_rodar if en_bolita else velocidad_maxima
	if en_bolita and is_on_floor():
		var normal_suelo := get_floor_normal()
		if absf(normal_suelo.x) > 0.05:
			velocity.x += normal_suelo.x * 780.0 * delta

	if entrada_x != 0.0:
		direccion_mirada = sign(entrada_x)
		var accel := aceleracion_suelo if is_on_floor() else aceleracion_aire
		if en_bolita:
			accel *= 0.85
		if en_bolita and absf(velocity.x) > vel_objetivo and signf(velocity.x) == signf(entrada_x):
			pass
		else:
			velocity.x = move_toward(velocity.x, entrada_x * vel_objetivo, accel * delta)
	else:
		var fric := friccion_rodar if (en_bolita and is_on_floor()) else (friccion_suelo if is_on_floor() else friccion_aire)
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	# Actualizar orientación de la zona de patada y ojos
	zona_patada.position.x = direccion_mirada * 34.0
	if temporizador_anim_patada <= 0.0:
		zona_patada.scale = Vector2(direccion_mirada, 1.0)
	ojos.position.x = lerp(ojos.position.x, direccion_mirada * 6.0, 14.0 * delta)

	# Acción de patada (E o Espacio)
	if Input.is_action_just_pressed("patada") and temporizador_patada <= 0.0 \
			and not en_bolita and not GameState.dialogo_abierto:
		_ejecutar_patada()

	# Poderes aprendidos
	if Input.is_action_just_pressed("grito") and GameState.grito_aprendido \
			and _cd_grito <= 0.0 and not GameState.dialogo_abierto:
		_ejecutar_grito()
	if Input.is_action_just_pressed("hielo") and GameState.hielo_aprendido \
			and _cd_hielo <= 0.0 and not GameState.dialogo_abierto:
		_ejecutar_hielo()
	if Input.is_action_just_pressed("talisman") and GameState.talisman_obtenido \
			and _cd_talisman <= 0.0 and not GameState.dialogo_abierto:
		_activar_talisman()

	move_and_slide()
	_empujar_cuerpos_fisicos()
	_animar_personaje(delta, entrada_x)


func _hacer_salto(es_doble: bool) -> void:
	if es_doble:
		if _saltos_usados >= 2:
			return
		_saltos_usados = 2
		velocity.y = velocidad_doble_salto
		temporizador_coyote = 0.0
		torso.scale = Vector2(0.72, 1.3)
		_giro_pendiente = TAU
		Efectos.anillo(global_position + Vector2(0, 18), Color(1.0, 0.86, 0.42),
				78.0, 5.0, 0.45)
		Efectos.chispas(global_position + Vector2(0, 20), Color(1.0, 0.95, 0.62),
				9, 46.0, 0.35)
		if _sonido_doble_salto:
			_sonido_doble_salto.play()
	else:
		_saltos_usados = 1
		velocity.y = velocidad_salto
		temporizador_coyote = 0.0
		torso.scale = Vector2(0.80, 1.24)
		if sonido_salto:
			sonido_salto.play()


func _actualizar_colision_bolita() -> void:
	if colision_cuerpo and colision_cuerpo.shape is CapsuleShape2D:
		var cap := colision_cuerpo.shape as CapsuleShape2D
		if en_bolita:
			cap.height = 44.0
			colision_cuerpo.position.y = 16.0
		else:
			cap.height = 76.0
			colision_cuerpo.position.y = 0.0


func _empujar_cuerpos_fisicos() -> void:
	for i in get_slide_collision_count():
		var colision := get_slide_collision(i)
		var objeto := colision.get_collider()
		if objeto is RigidBody2D:
			var normal := colision.get_normal()
			var impulso := Vector2(-normal.x, 0.0) * fuerza_empuje
			if impulso.length() > 0.0:
				objeto.apply_central_impulse(impulso)


func _ejecutar_patada() -> void:
	if not is_on_floor() and GameState.patada_voladora_aprendida:
		_ejecutar_patada_voladora()
		return

	temporizador_patada = enfriamiento_patada
	temporizador_anim_patada = 0.18
	efecto_patada.visible = false
	if sonido_patada:
		sonido_patada.play()
	var origen := global_position + Vector2(direccion_mirada * 30.0, 4.0)
	Efectos.corte(origen, direccion_mirada, Color(1.0, 0.92, 0.55, 0.95), 1.0, 0.22)
	Efectos.corte(origen + Vector2(direccion_mirada * 8.0, -6.0), direccion_mirada,
			Color(1.0, 1.0, 1.0, 0.7), 0.62, 0.18)
	Efectos.chispas(origen + Vector2(direccion_mirada * 18.0, 6.0),
			Color(1.0, 0.88, 0.45), 6, 34.0, 0.3)
	_golpear_zona("aereo" if not is_on_floor() else "normal")


func _ejecutar_patada_voladora() -> void:
	temporizador_patada = enfriamiento_voladora
	temporizador_anim_patada = 0.36
	efecto_patada.visible = false
	Efectos.corte(global_position + Vector2(direccion_mirada * 40.0, 4.0), direccion_mirada,
			Color(0.6, 0.95, 1.0, 0.95), 1.5, 0.3)
	zona_patada.scale = Vector2(direccion_mirada * 1.7, 1.4)
	velocity.x = direccion_mirada * impulso_patada_voladora
	velocity.y = minf(velocity.y, -150.0)
	_estela_restante = 0.36
	torso.scale = Vector2(1.2, 0.86)
	if _sonido_patada_voladora:
		_sonido_patada_voladora.play()
	Efectos.anillo(global_position, Color(0.6, 0.92, 1.0), 56.0, 3.0, 0.3)
	Efectos.destello(global_position + Vector2(direccion_mirada * 30.0, 8.0),
			Color(0.9, 0.98, 1.0), 26.0)
	_golpear_zona("voladora")


func _ejecutar_grito() -> void:
	_cd_grito = enfriamiento_grito
	_sacudida = 1.0
	torso.scale = Vector2(0.78, 1.26)
	if _sonido_grito:
		_sonido_grito.play()
	Efectos.onda(global_position + Vector2(0, -6), Color(1.0, 0.78, 0.32), radio_grito, 0.7)
	Efectos.anillo(global_position, Color(1, 1, 1, 0.85), radio_grito * 0.75, 5.0, 0.5)
	Efectos.chispas(global_position + Vector2(0, 6), Color(0.95, 0.9, 0.8), 14, 90.0, 0.5)

	for nodo in get_tree().get_nodes_in_group("destruible"):
		if nodo is Node2D and nodo.has_method("recibir_grito"):
			if (nodo as Node2D).global_position.distance_to(global_position) <= radio_grito:
				nodo.recibir_grito(direccion_mirada)
	for nodo in get_tree().get_nodes_in_group("enemigo"):
		if nodo is Node2D and nodo.has_method("recibir_grito"):
			if (nodo as Node2D).global_position.distance_to(global_position) <= radio_grito:
				nodo.recibir_grito(direccion_mirada)


func _ejecutar_hielo() -> void:
	_cd_hielo = enfriamiento_hielo
	if _sonido_hielo:
		_sonido_hielo.play()
	var centro := global_position + Vector2(direccion_mirada * 46.0, -4.0)
	Efectos.onda(centro, Color(0.55, 0.86, 1.0), radio_hielo * 0.75, 0.55)
	Efectos.destello(centro, Color(0.85, 0.97, 1.0), 42.0)
	Efectos.chispas(centro, Color(0.8, 0.95, 1.0), 16, 110.0, 0.5)

	for nodo in get_tree().get_nodes_in_group("enemigo"):
		if not (nodo is Node2D) or not nodo.has_method("congelar"):
			continue
		var delta_pos: Vector2 = (nodo as Node2D).global_position - global_position
		if delta_pos.length() > radio_hielo:
			continue
		if delta_pos.length() < 96.0 or signf(delta_pos.x) == direccion_mirada:
			nodo.congelar(4.5)


func _activar_talisman() -> void:
	_cd_talisman = enfriamiento_talisman
	_escudo_restante = duracion_escudo
	escudo_activo = true
	_burbuja.visible = true
	if _sonido_escudo:
		_sonido_escudo.play()
	Efectos.anillo(global_position, Color(0.55, 0.9, 1.0), 96.0, 6.0, 0.6)
	Efectos.chispas(global_position, Color(0.75, 0.95, 1.0), 12, 60.0, 0.4)


func recibir_dano(origen: Vector2) -> void:
	if _invulnerable > 0.0:
		return
	_invulnerable = 1.2
	GameState.perder_vida()
	var dir := signf(global_position.x - origen.x)
	if dir == 0.0:
		dir = 1.0
	velocity = Vector2(dir * 260.0, -240.0)
	_sacudida = 0.6
	torso.modulate = Color(1.0, 0.45, 0.45)
	await get_tree().create_timer(0.35).timeout
	torso.modulate = Color.WHITE
	if GameState.vidas <= 0:
		GameState.reiniciar_vidas()
		get_tree().reload_current_scene()


func _max_saltos() -> int:
	var extra := 0
	if GameState.doble_salto_aprendido:
		extra += 1
	if GameState.genio_completado:
		extra += 2
	return 1 + extra


func _golpear_zona(tipo: String) -> void:
	var golpeo_algo := false
	var escala := 1.7 if tipo == "voladora" else 1.0
	for cuerpo in zona_patada.get_overlapping_bodies():
		if cuerpo.has_method("recibir_patada"):
			cuerpo.recibir_patada(tipo)
			golpeo_algo = true
		elif cuerpo is RigidBody2D:
			var impulso := Vector2(direccion_mirada * fuerza_patada_x, fuerza_patada_y) * escala
			cuerpo.apply_central_impulse(impulso)
			golpeo_algo = true
	for area in zona_patada.get_overlapping_areas():
		if area.has_method("recibir_patada"):
			area.recibir_patada(tipo)
			golpeo_algo = true

	if golpeo_algo:
		if tipo == "voladora":
			velocity.x -= direccion_mirada * 260.0
			velocity.y = -180.0
		else:
			# Pequeño retroceso cómico al patear algo pesado
			velocity.x -= direccion_mirada * 65.0


func _animar_personaje(delta: float, entrada_x: float) -> void:
	torso.scale = torso.scale.lerp(Vector2.ONE, 12.0 * delta)

	# Modo bolita: esconder piernas y rodar
	if en_bolita:
		pierna_izq.visible = false
		pierna_der.visible = false
		cuerpo_visual.position.y = lerp(cuerpo_visual.position.y, 12.0, 14.0 * delta)
		cuerpo_visual.rotation += velocity.x * 0.022 * delta
		return
	else:
		pierna_izq.visible = true
		pierna_der.visible = true
		cuerpo_visual.position.y = lerp(cuerpo_visual.position.y, 0.0, 14.0 * delta)

	# Inclinación natural al correr
	var inclinacion_objetivo := clampf(velocity.x / velocidad_maxima, -1.0, 1.0) * 0.14
	cuerpo_visual.rotation = lerp_angle(cuerpo_visual.rotation, inclinacion_objetivo, 12.0 * delta)

	# Voltereta cómica durante el doble salto
	if _giro_pendiente > 0.0:
		_giro_pendiente -= 12.0 * delta
		var avance := 1.0 - maxf(_giro_pendiente, 0.0) / TAU
		cuerpo_visual.rotation = direccion_mirada * TAU * avance
		if _giro_pendiente <= 0.0:
			_giro_pendiente = 0.0
			cuerpo_visual.rotation = 0.0

	# Patada expresiva con pierna larga
	if temporizador_anim_patada > 0.0:
		var pie_patada := Vector2(direccion_mirada * 42.0, -8.0)
		var rodilla_patada := Vector2(direccion_mirada * 20.0, -6.0)
		if direccion_mirada > 0.0:
			_fijar_pierna(pierna_der, rodilla_patada, pie_patada)
			_fijar_pierna(pierna_izq, Vector2(-3, 14), Vector2(-4, 26))
		else:
			_fijar_pierna(pierna_izq, rodilla_patada, pie_patada)
			_fijar_pierna(pierna_der, Vector2(3, 14), Vector2(4, 26))
		return

	if not is_on_floor():
		# Piernas colgando juguetonas en el aire
		var arrastre := clampf(-velocity.x * 0.025, -8.0, 8.0)
		_fijar_pierna(pierna_izq, Vector2(arrastre * 0.5 - 4.0, 13.0), Vector2(arrastre - 6.0, 24.0))
		_fijar_pierna(pierna_der, Vector2(arrastre * 0.5 + 4.0, 13.0), Vector2(arrastre + 6.0, 24.0))
	elif tiempo_aterrizaje > 0.0:
		# Rodillas dobladas al aterrizar
		_fijar_pierna(pierna_izq, Vector2(-9.0, 12.0), Vector2(-2.0, 20.0))
		_fijar_pierna(pierna_der, Vector2(9.0, 12.0), Vector2(2.0, 20.0))
		torso.position.y = 4.0
	elif absf(velocity.x) > 18.0 and entrada_x != 0.0:
		# Zancadas cómicas estilo Pikuniku, reflejadas según la dirección
		tiempo_caminar += delta * 15.0
		var dir := direccion_mirada
		var paso_izq_x := sin(tiempo_caminar) * 14.0 * dir
		var paso_izq_y := 26.0 - maxf(0.0, cos(tiempo_caminar)) * 10.0
		var rodilla_izq := Vector2(paso_izq_x * 0.5 + dir * 5.0, (paso_izq_y * 0.5) - 2.0)
		_fijar_pierna(pierna_izq, rodilla_izq, Vector2(paso_izq_x + dir * 3.0, paso_izq_y))

		var paso_der_x := sin(tiempo_caminar + PI) * 14.0 * dir
		var paso_der_y := 26.0 - maxf(0.0, cos(tiempo_caminar + PI)) * 10.0
		var rodilla_der := Vector2(paso_der_x * 0.5 + dir * 5.0, (paso_der_y * 0.5) - 2.0)
		_fijar_pierna(pierna_der, rodilla_der, Vector2(paso_der_x + dir * 3.0, paso_der_y))

		torso.position.y = -absf(sin(tiempo_caminar)) * 4.0
	else:
		# Reposo
		tiempo_caminar = 0.0
		_fijar_pierna(pierna_izq, Vector2(-2.0, 13.0), Vector2(0.0, 26.0))
		_fijar_pierna(pierna_der, Vector2(2.0, 13.0), Vector2(0.0, 26.0))
		torso.position.y = lerp(torso.position.y, 0.0, 14.0 * delta)


func _fijar_pierna(pierna: Line2D, rodilla: Vector2, pie: Vector2) -> void:
	pierna.set_point_position(0, Vector2.ZERO)
	pierna.set_point_position(1, rodilla)
	pierna.set_point_position(2, pie)


func _configurar_controles() -> void:
	_asegurar_accion("mover_izquierda", [KEY_A, KEY_LEFT])
	_asegurar_accion("mover_derecha", [KEY_D, KEY_RIGHT])
	_asegurar_accion("saltar", [KEY_W, KEY_UP])
	_asegurar_accion("patada", [KEY_E, KEY_SPACE])
	_asegurar_accion("agacharse", [KEY_S, KEY_DOWN])
	_asegurar_accion("grito", [KEY_Q])
	_asegurar_accion("hielo", [KEY_F])
	_asegurar_accion("talisman", [KEY_T])


func _asegurar_accion(nombre: String, teclas: Array[Key]) -> void:
	if not InputMap.has_action(nombre):
		InputMap.add_action(nombre)
	for tecla in teclas:
		var ya_existe := false
		for ev in InputMap.action_get_events(nombre):
			if ev is InputEventKey and ev.keycode == tecla:
				ya_existe = true
				break
		if not ya_existe:
			var evento := InputEventKey.new()
			evento.keycode = tecla
			InputMap.action_add_event(nombre, evento)
