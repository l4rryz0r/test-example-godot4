class_name Hurtbox
extends Area2D

@export var health: Health

func receive(hit: DamageData) -> bool:
	return health.take_damage(hit)
