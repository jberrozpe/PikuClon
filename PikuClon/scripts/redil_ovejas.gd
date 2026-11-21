extends Area2D

@onready var sonido: AudioStreamPlayer2D = $SonidoExito


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if GameState.oveja_en_redil:
		var oveja := get_parent().get_node_or_null("Oveja")
		if oveja is RigidBody2D:
			oveja.global_position = global_position


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Oveja" and not GameState.oveja_en_redil:
		GameState.marcar_oveja_en_redil()
		if sonido:
			sonido.play()
