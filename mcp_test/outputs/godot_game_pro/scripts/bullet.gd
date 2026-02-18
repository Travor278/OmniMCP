extends Area2D
## 玩家子弹: 直线飞行, 碰到敌人造成伤害后消失

var speed: float = 600.0
var damage: float = 10.0
var direction: Vector2 = Vector2.RIGHT


func _ready():
	direction = Vector2.RIGHT.rotated(rotation)
	body_entered.connect(_on_body_entered)
	$LifeTimer.timeout.connect(queue_free)


func _physics_process(delta: float):
	position += direction * speed * delta


func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage)
	queue_free()


func _draw():
	draw_circle(Vector2.ZERO, 4, Color.YELLOW)
	draw_circle(Vector2.ZERO, 2, Color.WHITE)
