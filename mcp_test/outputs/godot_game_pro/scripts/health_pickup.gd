extends Area2D
## 生命恢复拾取物: 绿色十字, 接触玩家回复 HP

var heal_amount: float = 20.0
var bob_time: float = 0.0


func _ready():
	body_entered.connect(_on_body_entered)
	# 15 秒后自动消失
	var timer := Timer.new()
	timer.wait_time = 15.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()


func _physics_process(delta: float):
	bob_time += delta
	queue_redraw()


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		GameManager.heal(heal_amount)
		queue_free()


func _draw():
	var bob := sin(bob_time * 3.0) * 2.0
	draw_circle(Vector2(0, bob), 8, Color(0.2, 0.8, 0.2, 0.8))
	# 十字
	draw_line(Vector2(-4, bob), Vector2(4, bob), Color.WHITE, 2.5)
	draw_line(Vector2(0, bob - 4), Vector2(0, bob + 4), Color.WHITE, 2.5)
