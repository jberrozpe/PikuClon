extends Area2D

@onready var sonido_exito: AudioStreamPlayer2D = $SonidoExito


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if GameState.rayo_en_caja:
		var pelota := get_parent().get_node_or_null("PelotaRayo")
		if pelota is RigidBody2D:
			pelota.global_position = global_position + Vector2(0.0, -10.0)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "PelotaRayo":
		if not GameState.rayo_en_caja:
			GameState.marcar_rayo_en_caja()
			if sonido_exito:
				sonido_exito.play()
