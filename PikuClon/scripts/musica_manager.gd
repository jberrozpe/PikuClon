extends Node

const TEMAS := {
	"pueblo": "res://recursos/musica/pueblo.wav",
	"austria": "res://recursos/musica/austria.wav",
	"selva_negra": "res://recursos/musica/selva_negra.wav",
	"inglaterra": "res://recursos/musica/inglaterra.wav",
	"japon": "res://recursos/musica/japon.wav",
	"espana_boss": "res://recursos/musica/espana_boss.wav",
	"fiesta_final": "res://recursos/musica/fiesta_final.wav",
}

const MAPA_ESCENAS := {
	"res://escenas/pueblo.tscn": "pueblo",
	"res://escenas/nivel_prueba.tscn": "pueblo",
	"res://escenas/nivel_2.tscn": "pueblo",
	"res://escenas/nivel_austria.tscn": "austria",
	"res://escenas/nivel_selva_negra.tscn": "selva_negra",
	"res://escenas/nivel_inglaterra.tscn": "inglaterra",
	"res://escenas/nivel_japon.tscn": "japon",
	"res://escenas/nivel_espana.tscn": "espana_boss",
	"res://escenas/nivel_espana_boss.tscn": "espana_boss",
	"res://escenas/fiesta_final.tscn": "fiesta_final",
}

var _reproductor: AudioStreamPlayer
var _tema_actual: String = ""
var _ultima_escena: String = ""
var _ultimo_completado: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_reproductor = AudioStreamPlayer.new()
	_reproductor.name = "ReproductorMusica"
	_reproductor.volume_db = -10.0
	_reproductor.finished.connect(_on_musica_finished)
	add_child(_reproductor)


func _process(_delta: float) -> void:
	var escena := get_tree().current_scene
	if escena == null:
		return
	var ruta := escena.scene_file_path
	if ruta != _ultima_escena or GameState.juego_completado != _ultimo_completado:
		_ultima_escena = ruta
		_ultimo_completado = GameState.juego_completado
		var tema: String = MAPA_ESCENAS.get(ruta, "pueblo")
		if ruta == "res://escenas/pueblo.tscn" and GameState.juego_completado:
			tema = "fiesta_final"
		reproducir_tema(tema)


func reproducir_tema(nombre_tema: String) -> void:
	if nombre_tema == _tema_actual and _reproductor.playing:
		return
	if not TEMAS.has(nombre_tema):
		return

	var ruta: String = TEMAS[nombre_tema]
	var recurso := load(ruta)
	if recurso is AudioStreamWAV:
		var wav := recurso as AudioStreamWAV
		wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
		wav.loop_begin = 0
		wav.loop_end = int(wav.data.size() / 2)

	_reproductor.stop()
	_reproductor.stream = recurso
	_tema_actual = nombre_tema
	_reproductor.play()


func detener_musica() -> void:
	_reproductor.stop()
	_tema_actual = ""


func _on_musica_finished() -> void:
	if not _tema_actual.is_empty() and _reproductor.stream != null:
		_reproductor.play()
