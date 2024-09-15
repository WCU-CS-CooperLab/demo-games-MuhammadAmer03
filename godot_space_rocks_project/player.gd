extends RigidBody2D

@export var engine_power := 500
@export var spin_power := 8000
@export var bullet_scene : PackedScene
@export var fire_rate = 0.25

var can_shoot = true

var thrust := Vector2.ZERO
var rotation_dir := 0
var screensize := Vector2.ZERO

enum PlayerState {INIT, ALIVE, INVULNERABLE, DEAD}
var state := PlayerState.INIT

func _process(delta: float) -> void:
	get_input()
	
func get_input():
	thrust = Vector2.ZERO
	if state in [PlayerState.DEAD, PlayerState.INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left","rotate_right")
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot() -> void:
	if state == PlayerState.INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)


func _physics_process(delta):
	constant_force = thrust
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	var xform = physics_state.transform
	xform.origin.x = wrapf(xform.origin.x, 0, screensize.x)
	xform.origin.y = wrapf(xform.origin.y, 0, screensize.y)
	physics_state.transform = xform


func _ready() -> void:
	screensize = get_viewport_rect().size
	change_state(PlayerState.ALIVE)
	$GunCooldown.wait_time = fire_rate
	
func change_state(new_state: PlayerState):
	match new_state:
		PlayerState.INIT:
			$CollisionShape2D.set_deferred("disabled",true)
		PlayerState.ALIVE:
			$CollisionShape2D.set_deferred("disabled",false)
		PlayerState.INVULNERABLE:
			$CollisionShape2D.set_deferred("disabled",true)
		PlayerState.DEAD:
			$CollisionShape2D.set_deferred("disabled",true)
	state = new_state

func _on_gun_cooldown_timeout():
	can_shoot = true
