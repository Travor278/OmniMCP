extends CanvasLayer
## 暂停菜单: ESC 键触发, 可继续/重开/退出

var panel: PanelContainer


func _ready():
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	panel.visible = false


func _build_ui():
	# 半透明背景遮罩
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.5)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.size = Vector2(1280, 720)
	bg.visible = true
	bg.name = "BG"
	add_child(bg)

	panel = PanelContainer.new()
	panel.position = Vector2(440, 210)
	panel.custom_minimum_size = Vector2(400, 300)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var title := Label.new()
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	vbox.add_child(title)

	vbox.add_child(HSeparator.new())

	var resume_btn := Button.new()
	resume_btn.text = "Resume"
	resume_btn.custom_minimum_size.y = 40
	resume_btn.pressed.connect(_on_resume)
	vbox.add_child(resume_btn)

	var restart_btn := Button.new()
	restart_btn.text = "Restart"
	restart_btn.custom_minimum_size.y = 40
	restart_btn.pressed.connect(_on_restart)
	vbox.add_child(restart_btn)

	var quit_btn := Button.new()
	quit_btn.text = "Quit"
	quit_btn.custom_minimum_size.y = 40
	quit_btn.pressed.connect(_on_quit)
	vbox.add_child(quit_btn)


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause"):
		if GameManager.state == GameManager.State.PLAYING:
			_show_menu()
		elif GameManager.state == GameManager.State.PAUSED:
			_on_resume()


func _show_menu():
	GameManager.state = GameManager.State.PAUSED
	get_tree().paused = true
	panel.visible = true
	$BG.visible = true


func _on_resume():
	panel.visible = false
	$BG.visible = false
	GameManager.state = GameManager.State.PLAYING
	get_tree().paused = false


func _on_restart():
	panel.visible = false
	$BG.visible = false
	get_tree().paused = false
	GameManager.start_game()
	get_tree().reload_current_scene()


func _on_quit():
	get_tree().quit()
