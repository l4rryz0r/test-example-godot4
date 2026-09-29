extends Area2D

signal reached
var _clock: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and (body as Player).health.current > 0:
		reached.emit()

func _process(delta: float) -> void:
	_clock += delta
	queue_redraw()

func _draw() -> void:
	var mint := Color("6affdd")
	draw_rect(Rect2(-36, -103, 72, 103), Color("102e37"))
	draw_rect(Rect2(-36, -103, 72, 103), Color("3b6970"), false, 3)
	draw_rect(Rect2(-25, -90, 50, 90), Color(mint, 0.08 + sin(_clock * 2) * 0.03))
	draw_line(Vector2(-29, -93), Vector2(-29, -6), mint, 3)
	draw_line(Vector2(29, -93), Vector2(29, -6), mint, 3)
	for i in range(6):
		var y := -fmod(_clock * 26 + i * 16, 90.0)
		draw_line(Vector2(-24, y), Vector2(24, y), Color(mint, 0.15), 1)
	draw_string(ThemeDB.fallback_font, Vector2(-40, -122), "ВЫХОД", HORIZONTAL_ALIGNMENT_CENTER, 80, 17, mint)
	draw_line(Vector2(-10, -49), Vector2(12, -49), mint, 3)
	draw_polyline(PackedVector2Array([Vector2(5, -57), Vector2(13, -49), Vector2(5, -41)]), mint, 3, true)
