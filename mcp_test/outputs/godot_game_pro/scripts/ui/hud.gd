extends CanvasLayer
## HUD: 生命条、分数、波次、经验条、等级、波次公告

var health_bar: ProgressBar
var health_label: Label
var score_label: Label
var wave_label: Label
var xp_bar: ProgressBar
var level_label: Label
var highscore_label: Label
var wave_announce: Label
var announce_timer: float = 0.0


func _ready():
	layer = 10
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.health_changed.connect(_on_health_changed)
	GameManager.wave_changed.connect(_on_wave_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	_refresh_all()


func _build_ui():
	# ---- 左上角信息面板 ----
	var panel := PanelContainer.new()
	panel.position = Vector2(10, 10)
	panel.custom_minimum_size = Vector2(260, 0)
	add_child(panel)

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	# 波次
	wave_label = Label.new()
	wave_label.add_theme_font_size_override("font_size", 20)
	wave_label.text = "WAVE 0"
	vbox.add_child(wave_label)

	# 血条
	var hp_hbox := HBoxContainer.new()
	vbox.add_child(hp_hbox)
	var hp_icon := Label.new()
	hp_icon.text = "HP "
	hp_icon.add_theme_font_size_override("font_size", 16)
	hp_icon.add_theme_color_override("font_color", Color.RED)
	hp_hbox.add_child(hp_icon)
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(160, 18)
	health_bar.value = 100
	health_bar.show_percentage = false
	hp_hbox.add_child(health_bar)
	health_label = Label.new()
	health_label.add_theme_font_size_override("font_size", 14)
	hp_hbox.add_child(health_label)

	# 经验条
	var xp_hbox := HBoxContainer.new()
	vbox.add_child(xp_hbox)
	level_label = Label.new()
	level_label.text = "Lv.1 "
	level_label.add_theme_font_size_override("font_size", 16)
	level_label.add_theme_color_override("font_color", Color.CORNFLOWER_BLUE)
	xp_hbox.add_child(level_label)
	xp_bar = ProgressBar.new()
	xp_bar.custom_minimum_size = Vector2(130, 14)
	xp_bar.value = 0
	xp_bar.show_percentage = false
	xp_hbox.add_child(xp_bar)

	# ---- 右上角分数 ----
	score_label = Label.new()
	score_label.position = Vector2(1060, 12)
	score_label.add_theme_font_size_override("font_size", 24)
	score_label.text = "SCORE: 0"
	add_child(score_label)

	highscore_label = Label.new()
	highscore_label.position = Vector2(1060, 44)
	highscore_label.add_theme_font_size_override("font_size", 14)
	highscore_label.add_theme_color_override("font_color", Color.DIM_GRAY)
	highscore_label.text = "BEST: %d" % GameManager.high_score
	add_child(highscore_label)

	# ---- 波次公告 (屏幕中央) ----
	wave_announce = Label.new()
	wave_announce.position = Vector2(440, 280)
	wave_announce.add_theme_font_size_override("font_size", 52)
	wave_announce.add_theme_color_override("font_color", Color.GOLD)
	wave_announce.visible = false
	add_child(wave_announce)


func _process(delta: float):
	if announce_timer > 0:
		announce_timer -= delta
		if announce_timer < 1.0:
			wave_announce.modulate.a = announce_timer
		if announce_timer <= 0:
			wave_announce.visible = false


func _refresh_all():
	_on_health_changed(GameManager.player_health, GameManager.player_max_health)
	_on_score_changed(GameManager.score)
	_on_wave_changed(GameManager.current_wave)
	_on_xp_changed(GameManager.player_xp, GameManager.player_xp_to_next)


func _on_score_changed(new_score: int):
	score_label.text = "SCORE: %d" % new_score


func _on_health_changed(new_health: float, max_hp: float):
	if max_hp > 0:
		health_bar.value = (new_health / max_hp) * 100
	health_label.text = " %d/%d" % [int(new_health), int(max_hp)]


func _on_wave_changed(new_wave: int):
	wave_label.text = "WAVE %d" % new_wave
	wave_announce.text = "— WAVE %d —" % new_wave
	wave_announce.visible = true
	wave_announce.modulate = Color.WHITE
	announce_timer = 2.5


func _on_xp_changed(xp: int, xp_to_next: int):
	if xp_to_next > 0:
		xp_bar.value = (float(xp) / xp_to_next) * 100.0
	level_label.text = "Lv.%d " % GameManager.player_level
