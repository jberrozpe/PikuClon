extends Node2D

@export_enum("alcalde", "vecino1", "vecino2", "maquina") var rol: String = "alcalde"

var _jugador_cerca: bool = false
var _tiempo: float = 0.0
var _frases_actuales: Array[String] = []
var _indice_frase: int = 0

@onready var visual: Node2D = $Visual
@onready var zona: Area2D = $ZonaInteraccion
@onready var indicador: Control = $Indicador
@onready var bocadillo: Control = $Bocadillo
@onready var texto_bocadillo: Label = $Bocadillo/Texto
@onready var sonido_hablar: AudioStreamPlayer2D = $SonidoHablar


func _ready() -> void:
	indicador.visible = false
	bocadillo.visible = false
	zona.body_entered.connect(_on_body_entered)
	zona.body_exited.connect(_on_body_exited)


func _process(delta: float) -> void:
	_tiempo += delta
	if rol != "maquina":
		visual.scale.y = 1.0 + sin(_tiempo * 3.5) * 0.03


func _unhandled_input(event: InputEvent) -> void:
	if not _jugador_cerca:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_E:
		_avanzar_dialogo()


func _avanzar_dialogo() -> void:
	if not bocadillo.visible:
		_frases_actuales = _obtener_frases()
		_indice_frase = 0
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		bocadillo.visible = true
		indicador.visible = false
		if sonido_hablar:
			sonido_hablar.play()
		return

	_indice_frase += 1
	if _indice_frase < _frases_actuales.size():
		texto_bocadillo.text = _frases_actuales[_indice_frase]
		if sonido_hablar:
			sonido_hablar.play()
	else:
		bocadillo.visible = false
		indicador.visible = true
		_al_terminar_dialogo()


func _obtener_frases() -> Array[String]:
	match rol:
		"alcalde":
			if GameState.piezas_brillantes >= GameState.TOTAL_PIEZAS:
				return [
					"¡Lo conseguiste! ¡Has recuperado las 4 Piezas Brillantes!",
					"¡El pueblo entero está listo para el gran festival de fuegos artificiales!"
				]
			elif GameState.hablo_con_alcalde:
				return [
					"Recuerda: Don Cuadrado se llevó las 4 Piezas Brillantes.",
					"Usa el Globo Aerostático de la derecha para explorar nuevas zonas."
				]
			else:
				return [
					"¡Bienvenido al Pueblo! Soy el Alcalde.",
					"¡Un desastre! Don Cuadrado ha robado las 4 Piezas Brillantes de nuestra Máquina de Fuegos Artificiales.",
					"Necesitamos recuperarlas viajando en el Globo Aerostático. ¡Mientras tanto, habla con los vecinos!"
				]
		"vecino1":
			if GameState.vecino1_completado:
				return ["¡Esas Gafas de Sol te quedan increíbles! (Púlsalas con C o Tab en tu Armario)."]
			elif GameState.carta_tejados_recogida:
				return [
					"¡Mi carta! ¡La encontraste en las nubes sobre los tejados!",
					"Toma estas Gafas de Sol como agradecimiento. ¡Pruébatelas con C o Tab!"
				]
			else:
				return [
					"¡Ayuda! El viento se llevó mi carta hasta las nubes saltarinas encima de los tejados.",
					"Si subes por las nubes y me la traes, te regalo mis gafas favoritas."
				]
		"vecino2":
			if GameState.vecino2_completado:
				return ["¡Qué elegancia con esa corbata y esos guantes!"]
			elif GameState.mision_completada or GameState.mision_quesito_completada:
				return [
					"¡Me enteré de que ayudaste a nuestros amigos fuera del pueblo!",
					"Toma esta Corbata y estos Guantes Blancos para tu Armario (pulsa C o Tab)."
				]
			else:
				return [
					"¡Hola! Dicen que en la Zona de Pruebas o en casa de Don Quesito necesitan ayuda.",
					"Si viajas en el Globo y completas alguna de sus misiones, ¡te daré un premio muy elegante!"
				]
		"maquina":
			if GameState.piezas_brillantes >= GameState.TOTAL_PIEZAS:
				return ["¡MÁQUINA LISTA! Las 4 Piezas Brillantes están en su sitio. ¡A celebrar!"]
			else:
				return [
					"Máquina de Fuegos Artificiales (apagada).",
					"Faltan %d Piezas Brillantes para encenderla." % (GameState.TOTAL_PIEZAS - GameState.piezas_brillantes)
				]
	return ["¡Hola!"]


func _al_terminar_dialogo() -> void:
	match rol:
		"alcalde":
			GameState.registrar_charla_alcalde()
		"vecino1":
			if GameState.carta_tejados_recogida:
				GameState.completar_vecino1()
		"vecino2":
			if GameState.mision_completada or GameState.mision_quesito_completada:
				GameState.completar_vecino2()


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = true
		if not bocadillo.visible:
			indicador.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		_jugador_cerca = false
		indicador.visible = false
		bocadillo.visible = false
