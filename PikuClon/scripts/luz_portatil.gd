extends Sprite2D
## Halo de luz cálida que se cuelga del personaje (antorcha o lámpara).

@export var radio: float = 150.0
@export var color: Color = Color(1.0, 0.68, 0.3, 0.5)

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
	texture = textura
	scale = Vector2.ONE * (radio / 128.0)
	var material := CanvasItemMaterial.new()
	material.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
	self.material = material


func _process(delta: float) -> void:
	_tiempo += delta
	modulate.a = 0.8 + 0.2 * sin(_tiempo * 8.0)
