extends Node2D

const DESTINOS := [
	{"nombre": "Zona de Pruebas", "escena": "res://escenas/nivel_prueba.tscn", "punto": "", "disponible": true},
	{"nombre": "Casa de Don Quesito", "escena": "res://escenas/nivel_2.tscn", "punto": "PuntoDesdeNivel1", "disponible": true},
	{"nombre": "Montañas Austríacas", "escena": "res://escenas/nivel_austria.tscn", "punto": "", "disponible": true},
	{"nombre": "Selva Negra Alemana", "escena": "res://escenas/nivel_selva_negra.tscn", "punto": "", "disponible": true},
	{"nombre": "Campiña Inglesa", "escena": "res://escenas/nivel_inglaterra.tscn", "punto": "", "disponible": true},
	{"nombre": "Japón y su Volcán", "escena": "res://escenas/nivel_japon.tscn", "punto": "", "disponible": true},
	{"nombre": "España (Próximamente)", "escena": "", "punto": "", "disponible": false},
]

var _jugador_cerca: bool = false
var _tiempo: float = 0.0

@onready var visual: Sprite2D = $Visual
@onready var zona: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var menu_capa: CanvasLayer = $MenuViaje
@onready var contenedor_menu: Control = $MenuViaje/Contenedor
@onready var lista_destinos: VBoxContainer = $MenuViaje/Contenedor/Panel/ListaDestinos
@onready var sonido_viaje: AudioStreamPlayer2D = $SonidoViaje


func _ready() -> void:
	indicador.visible = false
	contenedor_menu.visible = false
	menu_capa.process_mode = Node.PROCESS_MODE_ALWAYS
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)
	_construir_destinos()


func _process(delta: float) -> void:
	_tiempo += delta
	visual.position.y = -75.0 + sin(_tiempo * 2.2) * 4.0


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E and _jugador_cerca:
			_alternar_menu()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_ESCAPE and contenedor_menu.visible:
			_cerrar_menu()
			get_viewport().set_input_as_handled()


func _alternar_menu() -> void:
	if contenedor_menu.visible:
		_cerrar_menu()
	else:
		contenedor_menu.visible = true
		indicador.visible = false
		get_tree().paused = true


func _cerrar_menu() -> void:
	contenedor_menu.visible = false
	get_tree().paused = false
	if _jugador_cerca:
		indicador.visible = true


func _construir_destinos() -> void:
	for dest in DESTINOS:
		var boton := Button.new()
		boton.text = dest["nombre"]
		boton.custom_minimum_size = Vector2(280, 32)
		boton.focus_mode = Control.FOCUS_NONE
		boton.disabled = not dest["disponible"]
		if dest["disponible"]:
			var ruta: String = dest["escena"]
			var punto: String = dest["punto"]
			boton.pressed.connect(func() -> void:
				_cerrar_menu()
				if sonido_viaje:
					sonido_viaje.play()
				GameState.ir_a_escena(ruta, punto)
			)
		lista_destinos.add_child(boton)

	var btn_cerrar := Button.new()
	btn_cerrar.text = "Cerrar [E / Esc]"
	btn_cerrar.custom_minimum_size = Vector2(280, 32)
	btn_cerrar.focus_mode = Control.FOCUS_NONE
	btn_cerrar.pressed.connect(_cerrar_menu)
	lista_destinos.add_child(btn_cerrar)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = true
		if not contenedor_menu.visible:
			indicador.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = false
		indicador.visible = false
