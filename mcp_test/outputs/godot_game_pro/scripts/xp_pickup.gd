extends Area2D
## 经验值拾取物: 蓝色光球, 靠近玩家时自动吸附

var xp_amount: int = 5
var bob_time: float = 0.0
var attract_speed: float = 250.0
var attract_range: float = 100.0


func _ready():
	body_entered.connect(_on_body_entered)
	# 20 秒后自动消失
	var timer := Timer.new()
	timer.wait_time = 20.0
	timer.one_shot = true
	timer.timeout.connect(queue_free)
	add_child(timer)
	timer.start()


func _physics_process(delta: float):
	bob_time += delta
	# 靠近玩家时吸附
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		var p = players[0]
		if is_instance_valid(p):
			var dist := global_position.distance_to(p.global_position)
			if dist < attract_range and dist > 5:
				var dir = (p.global_position - global_position).normalized()
				position += dir * attract_speed * delta
	queue_redraw()


func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		GameManager.add_xp(xp_amount)
		queue_free()


func _draw():
	var bob := sin(bob_time * 4.0) * 2.0
	draw_circle(Vector2(0, bob), 6, Color(0.3, 0.5, 1.0, 0.9))
	draw_circle(Vector2(0, bob), 3, Color(0.6, 0.8, 1.0))
