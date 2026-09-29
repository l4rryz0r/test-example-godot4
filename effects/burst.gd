extends Node2D

var color: Color = Color.WHITE
var count: int = 12
var _age: float = 0.0
var _velocities: Array[Vector2] = []

func _ready() -> void:
	for i in count:
		_velocities.append(Vector2.from_angle(TAU * i / count + randf() * 0.3) * randf_range(45, 160))

func _process(delta: float) -> void:
	_age += delta
	if _age > 0.55:
		queue_free()
	queue_redraw()

func _draw() -> void:
	for v in _velocities:
		var at := v * _age + Vector2(0, 100 * _age * _age)
		draw_line(at, at - v * 0.025, Color(color, 1.0 - _age / 0.55), 2, true)
	draw_arc(Vector2.ZERO, 6 + _age * 65, 0, TAU, 24, Color(color, maxf(0, 0.5 - _age)), 1, true)
