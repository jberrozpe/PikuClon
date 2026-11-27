extends Node2D
## Antorcha con halo cálido que parpadea.

@export var radio: float = 150.0
@export var color: Color = Color(1.0, 0.62, 0.25, 0.55)

var _halo: Sprite2D
var _tiempo: float = 0.0


func _ready() -> void:
	var gradiente := Gradient.new()
	gradiente.set_color(0, color)
	gradiente.set_color(1, Color(color.r, color.g, color.b, 0.0))
	var textura := GradientTexture2D.new()
	textura.gradient = gradiente
	textura.fill = GradientTexture2D.FILL_RADIAL
	textura.fill_from = Vector2(0.5, 0.5)
	textura.fill_to = Vector2(1.0, 0.5)
	textura.width = 256
	textura.height = 256

	_halo = Sprite2D.new()
	_halo.texture = textura
	_halo.position = Vector2(0, -40)
	_halo.scale = Vector2.ONE * (radio / 128.0)
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	_halo.material = material
	add_child(_halo)
	move_child(_halo, 0)


func _process(delta: float) -> void:
	_tiempo += delta
	if _halo != null:
		var pulso := 1.0 + sin(_tiempo * 7.0) * 0.05 + sin(_tiempo * 13.0) * 0.03
		_halo.scale = Vector2.ONE * (radio / 128.0) * pulso
		_halo.modulate.a = 0.75 + 0.25 * sin(_tiempo * 9.0)
