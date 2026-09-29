class_name Health
extends Node

signal changed(current: int, maximum: int)
signal damaged(hit: DamageData)
signal died

@export var maximum: int = 5
@export var invulnerability_duration: float = 0.85
var current: int
var invulnerability_left: float = 0.0

func _ready() -> void:
	current = maximum

func _physics_process(delta: float) -> void:
	invulnerability_left = maxf(0.0, invulnerability_left - delta)

func take_damage(hit: DamageData) -> bool:
	if current <= 0 or invulnerability_left > 0.0 or hit.amount <= 0:
		return false
	current = maxi(0, current - hit.amount)
	invulnerability_left = invulnerability_duration
	changed.emit(current, maximum)
	damaged.emit(hit)
	if current == 0:
		died.emit()
	return true

func eliminate() -> void:
	if current <= 0:
		return
	current = 0
	changed.emit(current, maximum)
	died.emit()
