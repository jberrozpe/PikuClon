extends AnimatableBody2D
## Plataforma que sube y baja (o va y viene) entre dos puntos.

@export var desplazamiento: Vector2 = Vector2(0, -180)
@export var duracion: float = 3.0

var _origen: Vector2
var _tiempo: float = 0.0


func _ready() -> void:
	_origen = position


func _physics_process(delta: float) -> void:
	_tiempo += delta
	var t := (sin(_tiempo * TAU / max(duracion, 0.2)) + 1.0) * 0.5
	position = _origen + desplazamiento * t
