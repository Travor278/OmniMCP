extends CanvasLayer
## 升级选择菜单: 升级时弹出 3 个随机选项, 玩家选择一个

var panel: PanelContainer
var bg: ColorRect
var buttons: Array[Button] = []
var upgrade_options: Array[Dictionary] = []
var level_display: Label

const ALL_UPGRADES: Array[Dictionary] = [
	{"type": "damage",       "name": "ATK UP",       "desc": "Damage +30%"},
	{"type": "fire_rate",    "name": "FIRE RATE",    "desc": "Shoot interval -20%"},
	{"type": "max_health",   "name": "VITALITY",     "desc": "Max HP +25"},
	{"type": "speed",        "name": "SWIFT",        "desc": "Move speed +30"},
	{"type": "bullet_speed", "name": "VELOCITY",     "desc": "Bullet speed +100"},
	{"type": "bullet_size",  "name": "BIG SHOT",     "desc": "Bullet size +30%"},
]


func _ready():
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	panel.visible = false
	bg.visible = false
	GameManager.show_upgrade_menu.connect(_show_upgrades)


func _build_ui():
	bg = ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.1, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	panel = PanelContainer.new()
	panel.position = Vector2(240, 200)
	panel.custom_minimum_size = Vector2(800, 320)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "LEVEL UP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(title)

	level_display = Label.new()
	level_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_display.add_theme_font_size_override("font_size", 16)
	vbox.add_child(level_display)

	vbox.add_child(HSeparator.new())

	var hbox := HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)
	vbox.add_child(hbox)

	for i in range(3):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(220, 100)
		btn.pressed.connect(_on_upgrade_selected.bind(i))
		hbox.add_child(btn)
		buttons.append(btn)


func _show_upgrades():
	panel.visible = true
	bg.visible = true
	level_display.text = "Reached Level %d" % GameManager.player_level

	var available := ALL_UPGRADES.duplicate()
	available.shuffle()
	upgrade_options.clear()
	for i in range(min(3, available.size())):
		upgrade_options.append(available[i])
		buttons[i].text = "%s\n%s" % [available[i]["name"], available[i]["desc"]]
		buttons[i].visible = true


func _on_upgrade_selected(index: int):
	if index < upgrade_options.size():
		GameManager.apply_upgrade(upgrade_options[index]["type"])
	panel.visible = false
	bg.visible = false
