extends Node2D
## Геометрия лаборатории в координатах мира: текстуры и внешние изображения не требуются.

const INK := Color("17293d")
const TEAL := Color("6affdd")
var _clock: float = 0.0

func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-1280, -720, 5500, 1900), Color("091322"))
	for x in range(-64, 3264, 64):
		draw_line(Vector2(x, 96), Vector2(x, 820), Color("101f31"))
	for y in range(96, 850, 64):
		draw_line(Vector2(0, y), Vector2(3200, y), Color("101f31"))
	for x in range(40, 3200, 320):
		draw_rect(Rect2(x, 175, 240, 245), Color("0d1b2c"))
		draw_rect(Rect2(x, 175, 240, 245), INK, false, 2)
		draw_line(Vector2(x + 12, 190), Vector2(x + 12, 402), Color("20364b"), 2)
		draw_rect(Rect2(x + 35, 196, 180, 3), Color("234155"))
		for i in range(5):
			draw_rect(Rect2(x + 178, 360 + i * 8, 38, 2), INK)
		draw_circle(Vector2(x + 217, 210), 3, Color(TEAL, 0.4))
	for x in range(0, 3200, 160):
		draw_rect(Rect2(x, 118, 110, 4), Color("244656"))
		draw_rect(Rect2(x + 12, 118, 85, 2), Color(TEAL, 0.35))
	draw_line(Vector2(0, 142), Vector2(3200, 142), INK, 2)
	draw_line(Vector2(0, 638), Vector2(3200, 638), INK, 2)
	for i in range(45):
		var p := Vector2(fmod(i * 79.0 + _clock * (4 + i % 3), 3200.0), 190 + fmod(i * 53.0 + sin(_clock + i) * 8, 390))
		draw_circle(p, 1.0, Color(TEAL, 0.2))
	# Смертельная пропасть визуально отличается от безопасных бирюзовых платформ.
	draw_rect(Rect2(0, 720, 3200, 150), Color("291b31"))
	for x in range(0, 3200, 28):
		draw_line(Vector2(x, 730), Vector2(x + 14, 744), Color("83445a"), 2)
