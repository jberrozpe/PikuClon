extends CharacterBody2D

@export_group("Movimiento")
@export var velocidad_maxima: float = 290.0
@export var velocidad_rodar: float = 350.0
@export var aceleracion_suelo: float = 1900.0
@export var friccion_suelo: float = 1700.0
@export var friccion_rodar: float = 420.0
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
	_configurar_controles()
	efecto_patada.visible = false
	_aplicar_punto_aparicion()
	_configurar_camara()
	_configurar_vestuario()
	GameState.zona_actual = nombre_zona
	GameState.mision_actualizada.emit()
	GameState.vestuario_cambiado.connect(_actualizar_vestuario)
	_actualizar_vestuario()


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
	camara.position_smoothing_enabled = true
	camara.position_smoothing_speed = camara_suavizado
	camara.enabled = true


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
	if temporizador_patada > 0.0:
		temporizador_patada -= delta
	if temporizador_anim_patada > 0.0:
		temporizador_anim_patada -= delta
		if temporizador_anim_patada <= 0.0:
			efecto_patada.visible = false
	if tiempo_aterrizaje > 0.0:
		tiempo_aterrizaje -= delta

	# Coyote time
	if is_on_floor():
		if not estaba_en_suelo:
			# Squash al aterrizar
			torso.scale = Vector2(1.24, 0.76)
			tiempo_aterrizaje = 0.14
		temporizador_coyote = coyote_time
	else:
		temporizador_coyote -= delta
	estaba_en_suelo = is_on_floor()

	# Gravedad diferenciada para un salto juguetón
	if not is_on_floor():
		var grav := gravedad_subida if velocity.y < 0.0 else gravedad_bajada
		velocity.y += grav * delta

	# Salto con coyote time y altura variable
	if Input.is_action_just_pressed("saltar") and temporizador_coyote > 0.0:
		velocity.y = velocidad_salto
		temporizador_coyote = 0.0
		torso.scale = Vector2(0.80, 1.24)
		if sonido_salto:
			sonido_salto.play()
	elif Input.is_action_just_released("saltar") and velocity.y < -120.0:
		velocity.y *= 0.52

	# Modo bolita / rodar (S o Flecha Abajo)
	en_bolita = Input.is_action_pressed("agacharse")

	# Movimiento lateral fluido
	var entrada_x := Input.get_axis("mover_izquierda", "mover_derecha")
	var vel_objetivo := velocidad_rodar if en_bolita else velocidad_maxima
	if entrada_x != 0.0:
		direccion_mirada = sign(entrada_x)
		var accel := aceleracion_suelo if is_on_floor() else aceleracion_aire
		if en_bolita:
			accel *= 0.85
		velocity.x = move_toward(velocity.x, entrada_x * vel_objetivo, accel * delta)
	else:
		var fric := friccion_rodar if (en_bolita and is_on_floor()) else (friccion_suelo if is_on_floor() else friccion_aire)
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	# Actualizar orientación de la zona de patada y ojos
	zona_patada.position.x = direccion_mirada * 34.0
	zona_patada.scale.x = direccion_mirada
	ojos.position.x = lerp(ojos.position.x, direccion_mirada * 6.0, 14.0 * delta)

	# Acción de patada (E o Espacio)
	if Input.is_action_just_pressed("patada") and temporizador_patada <= 0.0 and not en_bolita:
		_ejecutar_patada()

	move_and_slide()
	_empujar_cuerpos_fisicos()
	_animar_personaje(delta, entrada_x)


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
	temporizador_patada = enfriamiento_patada
	temporizador_anim_patada = 0.18
	efecto_patada.visible = true
	if sonido_patada:
		sonido_patada.play()

	var golpeo_algo := false
	for cuerpo in zona_patada.get_overlapping_bodies():
		if cuerpo is RigidBody2D:
			var impulso := Vector2(direccion_mirada * fuerza_patada_x, fuerza_patada_y)
			cuerpo.apply_central_impulse(impulso)
			golpeo_algo = true

	if golpeo_algo:
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
		# Zancadas cómicas estilo Pikuniku
		tiempo_caminar += delta * 15.0
		var paso_izq_x := sin(tiempo_caminar) * 14.0
		var paso_izq_y := 26.0 - maxf(0.0, cos(tiempo_caminar)) * 10.0
		var rodilla_izq := Vector2(paso_izq_x * 0.5 + direccion_mirada * 5.0, (paso_izq_y * 0.5) - 2.0)
		_fijar_pierna(pierna_izq, rodilla_izq, Vector2(paso_izq_x, paso_izq_y))

		var paso_der_x := sin(tiempo_caminar + PI) * 14.0
		var paso_der_y := 26.0 - maxf(0.0, cos(tiempo_caminar + PI)) * 10.0
		var rodilla_der := Vector2(paso_der_x * 0.5 + direccion_mirada * 5.0, (paso_der_y * 0.5) - 2.0)
		_fijar_pierna(pierna_der, rodilla_der, Vector2(paso_der_x, paso_der_y))

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
