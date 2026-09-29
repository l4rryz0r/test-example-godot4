extends CanvasLayer

signal restart_requested
signal resume_requested

const MINT := Color("6affdd")
const MUTED := Color("8298ac")
var _health_label: Label
var _cells: Array[ColorRect] = []
var _kills: Label
var _clock: Label
var _progress: ProgressBar
var _overlay: ColorRect
var _title: Label
var _description: Label
var _primary: Button
var _secondary: Button
var _mode: StringName = &""
var _sound_label: Label
var _eyebrow: Label
var _card: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)
	var top := PanelContainer.new()
	top.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 28
	top.offset_top = 22
	top.offset_right = -28
	top.add_theme_stylebox_override("panel", _panel(Color("0c1929"), Color("284154")))
	root.add_child(top)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 32)
	top.add_child(row)
	var hp := VBoxContainer.new()
	row.add_child(hp)
	_health_label = _label("ЦЕЛОСТНОСТЬ  5 / 5", 11, MUTED)
	hp.add_child(_health_label)
	var cells := HBoxContainer.new()
	cells.add_theme_constant_override("separation", 5)
	hp.add_child(cells)
	for i in 5:
		var cell := ColorRect.new()
		cell.custom_minimum_size = Vector2(29, 10)
		cell.color = MINT
		cells.add_child(cell)
		_cells.append(cell)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var objective := VBoxContainer.new()
	row.add_child(objective)
	objective.add_child(_label("ДОБЕРИТЕСЬ ДО ШЛЮЗА →", 12, MINT))
	_progress = ProgressBar.new()
	_progress.custom_minimum_size = Vector2(230, 4)
	_progress.show_percentage = false
	_progress.add_theme_stylebox_override("background", _flat(Color("203346")))
	_progress.add_theme_stylebox_override("fill", _flat(MINT))
	objective.add_child(_progress)
	_kills = _label("СТРАЖИ  0 / 6", 13, MUTED)
	row.add_child(_kills)
	_clock = _label("00:00", 20, Color("e0f4ef"))
	row.add_child(_clock)
	var footer := Panel.new()
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -55
	footer.add_theme_stylebox_override("panel", _panel(Color("0b1726"), Color("21394b"), 0))
	root.add_child(footer)
	var bottom := HBoxContainer.new()
	bottom.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 32
	bottom.offset_right = -32
	bottom.offset_top = -47
	bottom.add_theme_constant_override("separation", 24)
	root.add_child(bottom)
	for hint in ["A / D  ВЛЕВО / ВПРАВО", "W  ПРЫЖОК", "ПРОБЕЛ  ПРЫЖОК", "J / ЛКМ  УДАР", "R  ЗАНОВО", "ESC  ПАУЗА"]:
		bottom.add_child(_label(hint, 11, MUTED))
	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(bottom_spacer)
	_sound_label = _label("M  ЗВУК ВКЛ", 11, MINT)
	bottom.add_child(_sound_label)
	_overlay = ColorRect.new()
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color(0.025, 0.05, 0.09, 0.88)
	root.add_child(_overlay)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(center)
	var card := PanelContainer.new()
	_card = card
	card.custom_minimum_size = Vector2(530, 340)
	card.add_theme_stylebox_override("panel", _panel(Color("101f31"), Color("365767"), 36))
	center.add_child(card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	card.add_child(column)
	_eyebrow = _label("ЛАБОРАТОРИЯ 07 / ТЕРМИНАЛ", 11, MINT)
	column.add_child(_eyebrow)
	_title = _label("", 38, Color("ecfff9"))
	column.add_child(_title)
	_description = _label("", 16, MUTED)
	column.add_child(_description)
	_primary = _button("ПОВТОРИТЬ ПОПЫТКУ", true)
	_primary.pressed.connect(_primary_pressed)
	column.add_child(_primary)
	_secondary = _button("НАЧАТЬ ЗАНОВО", false)
	_secondary.pressed.connect(func() -> void: restart_requested.emit())
	column.add_child(_secondary)
	_overlay.hide()

func set_health(current: int, maximum: int) -> void:
	_health_label.text = "ЦЕЛОСТНОСТЬ  %d / %d" % [current, maximum]
	for i in _cells.size():
		_cells[i].color = (Color("ff637d") if current <= 2 else MINT) if i < current else Color("24374a")

func update_run(seconds: float, distance: float, kills: int, total: int) -> void:
	_clock.text = "%02d:%02d" % [int(seconds) / 60, int(seconds) % 60]
	_progress.value = clampf(distance, 0.0, 1.0) * 100.0
	_kills.text = "СТРАЖИ  %d / %d" % [kills, total]

func show_result(won: bool, seconds: float, kills: int, total: int) -> void:
	_mode = &"result"
	_eyebrow.show()
	_description.show()
	_card.custom_minimum_size.y = 340
	_title.text = "ПОБЕГ УДАЛСЯ" if won else "GAME OVER"
	_title.modulate = MINT if won else Color("ff7189")
	_description.text = ("Шлюз открыт. Вы выбрались из лаборатории.\nВремя: %.1f с  ·  Стражи: %d / %d" % [seconds, kills, total]) if won else "Сигнал потерян. Корпус уничтожен.\nПерезапуск через 3 секунды…"
	_primary.text = "ЕЩЁ ОДНА ПОПЫТКА  [R]"
	_secondary.hide()
	_overlay.show()
	_primary.grab_focus()

func show_pause(paused: bool) -> void:
	_mode = &"pause"
	_overlay.visible = paused
	if paused:
		_eyebrow.hide()
		_description.hide()
		_card.custom_minimum_size.y = 0
		_title.text = "ПАУЗА"
		_title.modulate = Color.WHITE
		_primary.text = "ПРОДОЛЖИТЬ  [ESC]"
		_secondary.show()
		_primary.grab_focus()

func set_muted(muted: bool) -> void:
	_sound_label.text = "M  ЗВУК ВЫКЛ" if muted else "M  ЗВУК ВКЛ"

func _primary_pressed() -> void:
	if _mode == &"pause":
		resume_requested.emit()
	else:
		restart_requested.emit()

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 48
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color("0c202a") if primary else MINT)
	button.add_theme_color_override("font_focus_color", Color("0c202a") if primary else MINT)
	button.add_theme_color_override("font_pressed_color", Color("0c202a"))
	button.add_theme_color_override("font_hover_color", Color("0c202a"))
	button.add_theme_stylebox_override("normal", _panel(MINT if primary else Color("142c3b"), MINT, 12))
	button.add_theme_stylebox_override("hover", _panel(Color("b2ffe9"), MINT, 12))
	button.add_theme_stylebox_override("focus", _panel(Color(0, 0, 0, 0), Color.WHITE, 12))
	return button

func _flat(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	return style

func _panel(color: Color, border: Color, padding: int = 16) -> StyleBoxFlat:
	var style := _flat(color)
	style.border_color = border
	style.set_border_width_all(1)
	style.set_content_margin_all(padding)
	style.set_corner_radius_all(3)
	return style
