extends Path2D

@export var velocidad_rizo: float = 540.0
@export var velocidad_salida: Vector2 = Vector2(460.0, -150.0)

var _jugador_activo: CharacterBody2D = null
var _enfriamiento: float = 0.0

@onready var seguidor: PathFollow2D = $Seguidor
@onready var pista_visual: Line2D = $PistaVisual
@onready var entrada: Area2D = $EntradaRizo


func _ready() -> void:
	if curve != null and pista_visual != null:
		pista_visual.points = curve.get_baked_points()
	entrada.body_entered.connect(_on_entrada_body_entered)


func _physics_process(delta: float) -> void:
	if _enfriamiento > 0.0:
		_enfriamiento -= delta

	if _jugador_activo != null:
		seguidor.progress += velocidad_rizo * delta
		_jugador_activo.global_position = seguidor.global_position
		_jugador_activo.cuerpo_visual.rotation += 12.0 * delta

		if seguidor.progress_ratio >= 0.99:
			_jugador_activo._en_rizo = false
			_jugador_activo.velocity = velocidad_salida
			_jugador_activo = null
			_enfriamiento = 0.6


func _on_entrada_body_entered(body: Node2D) -> void:
	if _jugador_activo != null or _enfriamiento > 0.0:
		return
	if body is CharacterBody2D and body.get("en_bolita") == true and body.velocity.x > 120.0:
		_jugador_activo = body as CharacterBody2D
		_jugador_activo._en_rizo = true
		seguidor.progress = 0.0
