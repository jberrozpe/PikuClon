extends Node
## Pone el juego en pantalla completa nativa del sistema al arrancar.
##
## Usa el modo "fullscreen" del propio sistema operativo (en macOS, el espacio
## de pantalla completa nativo), así que el juego siempre ocupa la resolución
## real del monitor. Con F11 se alterna entre pantalla completa y una ventana
## de 1152x648 centrada.

const ANCHO_VENTANA := 1152
const ALTO_VENTANA := 648
const TECLA_ALTERNAR := KEY_F11

var pantalla_completa := true


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ir_a_pantalla_completa()


func _input(evento: InputEvent) -> void:
	if evento is InputEventKey and evento.pressed and not evento.echo \
			and evento.keycode == TECLA_ALTERNAR:
		pantalla_completa = not pantalla_completa
		if pantalla_completa:
			_ir_a_pantalla_completa()
		else:
			_ir_a_ventana()
		get_viewport().set_input_as_handled()


func _ir_a_pantalla_completa() -> void:
	var ventana := get_window()
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	ventana.current_screen = DisplayServer.window_get_current_screen()
	pantalla_completa = true


func _ir_a_ventana() -> void:
	var ventana := get_window()
	var tamano := Vector2i(ANCHO_VENTANA, ALTO_VENTANA)
	var indice := ventana.current_screen
	var pantalla := DisplayServer.screen_get_size(indice)
	var origen := DisplayServer.screen_get_position(indice)

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(tamano)
	DisplayServer.window_set_position(origen + (pantalla - tamano) / 2)
	pantalla_completa = false
