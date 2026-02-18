extends CanvasLayer
## 游戏结束画面: 显示分数、最高分, 可重开/退出

var panel: PanelContainer
var score_display: Label
var high_score_display: Label
var bg: ColorRect


func _ready():
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	panel.visible = false
	bg.visible = false
	GameManager.game_over_triggered.connect(_show_screen)


func _build_ui():
	bg = ColorRect.new()
	bg.color = Color(0.1, 0.0, 0.0, 0.6)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	add_child(bg)

	panel = PanelContainer.new()
	panel.position = Vector2(390, 180)
	panel.custom_minimum_size = Vector2(500, 360)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "GAME OVER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color.INDIAN_RED)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	score_display = Label.new()
	score_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_display.add_theme_font_size_override("font_size", 24)
	vbox.add_child(score_display)

	high_score_display = Label.new()
	high_score_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	high_score_display.add_theme_font_size_override("font_size", 18)
	high_score_display.add_theme_color_override("font_color", Color.GOLD)
	vbox.add_child(high_score_display)

	var wave_display := Label.new()
	wave_display.name = "WaveDisplay"
	wave_display.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_display.add_theme_font_size_override("font_size", 16)
	wave_display.add_theme_color_override("font_color", Color.DIM_GRAY)
	vbox.add_child(wave_display)

	vbox.add_child(HSeparator.new())

	var restart_btn := Button.new()
	restart_btn.text = "Restart"
	restart_btn.custom_minimum_size.y = 44
	restart_btn.pressed.connect(_on_restart)
	vbox.add_child(restart_btn)

	var quit_btn := Button.new()
	quit_btn.text = "Quit"
	quit_btn.custom_minimum_size.y = 44
	quit_btn.pressed.connect(_on_quit)
	vbox.add_child(quit_btn)


func _show_screen():
	panel.visible = true
	bg.visible = true
	score_display.text = "Score: %d" % GameManager.score
	if GameManager.score >= GameManager.high_score and GameManager.score > 0:
		high_score_display.text = "NEW RECORD! Best: %d" % GameManager.high_score
	else:
		high_score_display.text = "Best: %d" % GameManager.high_score
	var wave_lbl = panel.find_child("WaveDisplay")
	if wave_lbl:
		wave_lbl.text = "Survived %d waves  |  Level %d" % [GameManager.current_wave, GameManager.player_level]


func _on_restart():
	panel.visible = false
	bg.visible = false
	get_tree().paused = false
	GameManager.start_game()
	get_tree().reload_current_scene()


func _on_quit():
	get_tree().quit()
