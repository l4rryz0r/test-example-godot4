extends Node

signal pause_requested
signal restart_requested
signal mute_requested

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		pause_requested.emit()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"restart"):
		restart_requested.emit()
	elif event.is_action_pressed(&"mute"):
		mute_requested.emit()
