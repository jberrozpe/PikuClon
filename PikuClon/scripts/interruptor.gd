extends Node2D

signal activado
signal desactivado
signal estado_cambiado(esta_activo: bool)

@export var color_reposo: Color = Color(0.901961, 0.25098, 0.25098, 1.0)
@export var color_activo: Color = Color(0.25098, 0.819608, 0.45098, 1.0)
@export var hundimiento: float = 7.0
@export var velocidad_animacion: float = 14.0

var _cuerpos_encima: Array[Node2D] = []
var _esta_activo: bool = false
var _pos_y_inicial: float = 0.0

@onready var tapa: ColorRect = $Tapa
@onready var zona_deteccion: Area2D = $ZonaDeteccion


func _ready() -> void:
	_pos_y_inicial = tapa.position.y
	tapa.color = color_reposo
	zona_deteccion.body_entered.connect(_on_body_entered)
	zona_deteccion.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	var factor := clampf(velocidad_animacion * delta, 0.0, 1.0)
	var pos_objetivo := _pos_y_inicial + (hundimiento if _esta_activo else 0.0)
	tapa.position.y = lerpf(tapa.position.y, pos_objetivo, factor)

	var color_objetivo := color_activo if _esta_activo else color_reposo
	tapa.color = tapa.color.lerp(color_objetivo, factor)


func _on_body_entered(body: Node2D) -> void:
	if _es_cuerpo_valido(body) and not _cuerpos_encima.has(body):
		_cuerpos_encima.append(body)
		_actualizar_estado()


func _on_body_exited(body: Node2D) -> void:
	if _cuerpos_encima.has(body):
		_cuerpos_encima.erase(body)
		_actualizar_estado()


func _es_cuerpo_valido(body: Node2D) -> bool:
	return body is CharacterBody2D or body is RigidBody2D


func _actualizar_estado() -> void:
	_cuerpos_encima = _cuerpos_encima.filter(func(c: Node2D) -> bool: return is_instance_valid(c))
	var nuevo_estado := _cuerpos_encima.size() > 0
	if nuevo_estado != _esta_activo:
		_esta_activo = nuevo_estado
		estado_cambiado.emit(_esta_activo)
		if _esta_activo:
			activado.emit()
		else:
			desactivado.emit()
