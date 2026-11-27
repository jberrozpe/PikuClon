class_name Efectos
extends RefCounted
## Efectos visuales de un solo uso (anillos, chispas, estelas y trozos).
##
## Se crean en la escena actual y se autodestruyen con un tween, así que
## cualquier script puede invocarlos sin gestionar nada.

static func _raiz() -> Node:
	var arbol := Engine.get_main_loop() as SceneTree
	if arbol == null:
		return null
	return arbol.current_scene


static func anillo(
		pos: Vector2,
		color: Color,
		radio_max: float = 70.0,
		grosor: float = 4.0,
		duracion: float = 0.45
) -> void:
	var raiz := _raiz()
	if raiz == null:
		return
	var aro := Line2D.new()
	aro.width = grosor
	aro.default_color = color
	aro.closed = true
	aro.joint_mode = Line2D.LINE_JOINT_ROUND
	aro.z_index = 5
	var radio_base := 12.0
	for i in range(20):
		var angulo := TAU * float(i) / 20.0
		aro.add_point(Vector2(cos(angulo), sin(angulo)) * radio_base)
	aro.position = pos
	aro.scale = Vector2.ONE * 0.4
	raiz.add_child(aro)

	var tw := aro.create_tween()
	tw.set_parallel(true)
	tw.tween_property(aro, "scale", Vector2.ONE * (radio_max / radio_base), duracion) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(aro, "modulate:a", 0.0, duracion)
	tw.chain().tween_callback(aro.queue_free)


static func chispas(
		pos: Vector2,
		color: Color,
		cantidad: int = 10,
		alcance: float = 54.0,
		duracion: float = 0.4
) -> void:
	var raiz := _raiz()
	if raiz == null:
		return
	for i in range(cantidad):
		var chispa := Polygon2D.new()
		var tam := randf_range(2.5, 5.0)
		chispa.polygon = PackedVector2Array([
			Vector2(-tam, -tam), Vector2(tam, -tam), Vector2(tam, tam), Vector2(-tam, tam),
		])
		chispa.color = color
		chispa.position = pos
		chispa.z_index = 6
		raiz.add_child(chispa)

		var angulo := randf_range(0.0, TAU)
		var destino := pos + Vector2(cos(angulo), sin(angulo) - 0.6) \
				* randf_range(alcance * 0.4, alcance)
		var tw := chispa.create_tween()
		tw.set_parallel(true)
		tw.tween_property(chispa, "position", destino, duracion).set_ease(Tween.EASE_OUT)
		tw.tween_property(chispa, "modulate:a", 0.0, duracion)
		tw.tween_property(chispa, "rotation", randf_range(-4.0, 4.0), duracion)
		tw.chain().tween_callback(chispa.queue_free)


static func estela(
		pos: Vector2,
		direccion: float,
		color: Color,
		largo: float = 46.0
) -> void:
	var raiz := _raiz()
	if raiz == null:
		return
	var marca := Polygon2D.new()
	marca.polygon = PackedVector2Array([
		Vector2(0, -9), Vector2(-largo, -3), Vector2(-largo * 0.8, 3), Vector2(0, 9),
	])
	marca.color = color
	marca.position = pos
	marca.scale.x = direccion
	marca.z_index = 4
	raiz.add_child(marca)

	var tw := marca.create_tween()
	tw.set_parallel(true)
	tw.tween_property(marca, "modulate:a", 0.0, 0.3)
	tw.tween_property(marca, "position:x", pos.x - direccion * 20.0, 0.3)
	tw.chain().tween_callback(marca.queue_free)


static func trozos(
		pos: Vector2,
		color: Color,
		cantidad: int = 6,
		alcance: float = 90.0
) -> void:
	var raiz := _raiz()
	if raiz == null:
		return
	for i in range(cantidad):
		var trozo := Polygon2D.new()
		var tam := randf_range(5.0, 10.0)
		trozo.polygon = PackedVector2Array([
			Vector2(-tam, -tam * 0.6), Vector2(tam * 0.7, -tam),
			Vector2(tam, tam * 0.5), Vector2(-tam * 0.6, tam),
		])
		trozo.color = color
		trozo.position = pos
		trozo.z_index = 6
		raiz.add_child(trozo)

		var destino := pos + Vector2(
			randf_range(-alcance, alcance),
			randf_range(-alcance * 0.8, alcance * 0.45)
		)
		var tw := trozo.create_tween()
		tw.set_parallel(true)
		tw.tween_property(trozo, "position", destino, 0.7).set_ease(Tween.EASE_OUT) \
				.set_trans(Tween.TRANS_QUAD)
		tw.tween_property(trozo, "rotation", randf_range(-6.0, 6.0), 0.7)
		tw.tween_property(trozo, "modulate:a", 0.0, 0.7)
		tw.chain().tween_callback(trozo.queue_free)


static func destello(pos: Vector2, color: Color, radio: float = 34.0) -> void:
	var raiz := _raiz()
	if raiz == null:
		return
	var brillo := Polygon2D.new()
	var puntos := PackedVector2Array()
	for i in range(8):
		var angulo := TAU * float(i) / 8.0
		var r := radio if i % 2 == 0 else radio * 0.34
		puntos.append(Vector2(cos(angulo), sin(angulo)) * r)
	brillo.polygon = puntos
	brillo.color = color
	brillo.position = pos
	brillo.z_index = 7
	brillo.scale = Vector2.ONE * 0.3
	raiz.add_child(brillo)

	var tw := brillo.create_tween()
	tw.set_parallel(true)
	tw.tween_property(brillo, "scale", Vector2.ONE * 1.5, 0.22).set_ease(Tween.EASE_OUT)
	tw.tween_property(brillo, "modulate:a", 0.0, 0.22)
	tw.chain().tween_callback(brillo.queue_free)


## Media luna de un golpe (patada, grito...). Se abre y se desvanece.
static func corte(
		pos: Vector2,
		direccion: float,
		color: Color,
		tamano: float = 1.0,
		duracion: float = 0.22
) -> void:
	var raiz := _raiz()
	if raiz == null:
		return
	var golpe := Polygon2D.new()
	var r_ext := 46.0 * tamano
	var r_int := 17.0 * tamano
	var puntos := PackedVector2Array()
	for i in range(14):
		var a := lerpf(-1.05, 1.05, float(i) / 13.0)
		puntos.append(Vector2(cos(a) * r_ext, sin(a) * r_ext))
	for i in range(14):
		var a := lerpf(1.05, -1.05, float(i) / 13.0)
		puntos.append(Vector2(cos(a) * r_int, sin(a) * r_int))
	golpe.polygon = puntos
	golpe.color = color
	golpe.position = pos
	golpe.scale = Vector2(direccion, 1.0)
	golpe.z_index = 6
	raiz.add_child(golpe)

	var tw := golpe.create_tween()
	tw.set_parallel(true)
	tw.tween_property(golpe, "scale", Vector2(direccion * 1.4, 1.4), duracion) \
			.set_ease(Tween.EASE_OUT)
	tw.tween_property(golpe, "rotation", direccion * 0.75, duracion)
	tw.tween_property(golpe, "modulate:a", 0.0, duracion)
	tw.chain().tween_callback(golpe.queue_free)


## Onda de choque doble (grito gutural, magia de hielo).
static func onda(pos: Vector2, color: Color, radio: float = 170.0, dur: float = 0.6) -> void:
	anillo(pos, color, radio, 9.0, dur)
	anillo(pos, Color(color.r, color.g, color.b, 0.65), radio * 0.62, 5.0, dur * 0.7)
