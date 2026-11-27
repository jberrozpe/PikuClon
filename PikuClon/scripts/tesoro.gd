extends Area2D
## Tesoro de la cueva de Ali Babá.

var _cogido: bool = false

@onready var visual: Node2D = $Visual
@onready var sonido: AudioStreamPlayer = get_node_or_null("Sonido")


func _ready() -> void:
	if GameState.tesoro_recogido:
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _cogido or not (body is CharacterBody2D):
		return
	_cogido = true
	GameState.recoger_tesoro()
	if sonido != null:
		sonido.play()
	Efectos.destello(global_position, Color(1, 0.9, 0.4), 64.0)
	Efectos.anillo(global_position, Color(1, 0.85, 0.3), 150.0, 7.0, 0.9)
	Efectos.chispas(global_position, Color(1, 0.86, 0.32), 26, 130.0, 0.9)
	if visual != null:
		visual.visible = false
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.1).timeout
	queue_free()
