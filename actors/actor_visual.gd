class_name ActorVisual
extends Node2D
## Небольшой векторный робот: анимация не изменяет геометрию коллизий.

@export var hostile: bool = false
var facing: float = 1.0
var speed: float = 0.0
var grounded: bool = true
var swing: float = 0.0
var warning: float = 0.0
var health_ratio: float = 1.0
var flash: float = 0.0
var phase: float = 0.0

func _process(delta: float) -> void:
	phase += delta * (16.0 if absf(speed) > 20.0 else 3.0)
	queue_redraw()

func _draw() -> void:
	var accent := Color("ff637d") if hostile else Color("6affdd")
	var shell := Color("573145") if hostile else Color("d7f7ed")
	if flash > 0.1:
		shell = Color.WHITE
		accent = Color.WHITE
	var bob := sin(phase) * (1.5 if grounded else 0.0)
	var step := sin(phase) * 5.0 if grounded and absf(speed) > 20.0 else 0.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(facing, 1.0))
	draw_circle(Vector2(0, -22), 30, Color(accent, 0.035))
	draw_rect(Rect2(-13, -37 + bob, 26, 25), shell)
	draw_rect(Rect2(-11, -47 + bob, 24, 16), shell)
	draw_rect(Rect2(-5, -43 + bob, 21, 7), Color("101d30"))
	draw_rect(Rect2(3, -42 + bob, 12, 4), accent)
	draw_rect(Rect2(-9, -28 + bob, 5, 9), Color("22384c"))
	draw_rect(Rect2(0, -26 + bob, 7, 4), accent)
	draw_rect(Rect2(-12, -14, 8, 13 + step), Color("526778"))
	draw_rect(Rect2(4, -14, 8, 13 - step), Color("526778"))
	draw_rect(Rect2(-14, -4 + step, 13, 4), shell)
	draw_rect(Rect2(3, -4 - step, 13, 4), shell)
	draw_rect(Rect2(-18, -33 + bob, 6, 16), Color("34495e"))
	draw_rect(Rect2(12, -30 + bob, 8, 13), shell)
	draw_line(Vector2(17, -21), Vector2(30, -27), accent, 4, true)
	if swing > 0.0:
		var alpha := clampf(swing * 4.0, 0.0, 1.0)
		draw_arc(Vector2(9, -25), 51, -1.25, 1.15, 24, Color(accent, alpha * 0.18), 16, true)
		draw_arc(Vector2(9, -25), 54, -1.15, 1.05, 24, Color(accent, alpha), 4, true)
		draw_line(Vector2(19, -25), Vector2(65, -30), Color("f0fff9"), 2, true)
	draw_set_transform(Vector2.ZERO)
	if hostile:
		draw_rect(Rect2(-18, -60, 36, 3), Color("243347"))
		draw_rect(Rect2(-18, -60, 36 * health_ratio, 3), accent)
	if warning > 0.0:
		draw_circle(Vector2(0, -79), 11, Color("ffb95c"))
		draw_line(Vector2(0, -85), Vector2(0, -79), Color("1a2030"), 3)
		draw_circle(Vector2(0, -74), 1.5, Color("1a2030"))
		draw_arc(Vector2.ZERO, 56, PI, TAU, 24, Color("ffb95c", 0.55), 2, true)
