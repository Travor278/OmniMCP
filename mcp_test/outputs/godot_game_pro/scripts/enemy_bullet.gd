extends Area2D
## 敌方子弹: 直线飞行, 碰到玩家造成伤害

var speed: float = 300.0
var damage: float = 8.0
var direction: Vector2 = Vector2.RIGHT


func _ready():
	body_entered.connect(_on_body_entered)
	$LifeTimer.timeout.connect(queue_free)


func _physics_process(delta: float):
	position += direction * speed * delta


func _on_body_entered(body: Node2D):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()


func _draw():
	draw_circle(Vector2.ZERO, 3, Color.RED)
	draw_circle(Vector2.ZERO, 1.5, Color.ORANGE)
