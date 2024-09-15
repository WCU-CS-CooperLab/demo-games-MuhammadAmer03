extends Area2D

@export var speed = 1000

var velocity = Vector2.ZERO

func start(_transform):
	transform = _transform
	velocity = transform.x * speed
	
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	position += velocity * delta

func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()
	
func _on_body_entered(body):
	if body.is_in_group("rocks"):
		body.explode()
		queue_free()
