extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -700.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 1500
@export var player_life = 10
var knockback_vector := Vector2.ZERO
@onready var remote_transform := $Remote as RemoteTransform2D

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if knockback_vector != Vector2.ZERO:
		velocity = knockback_vector


	move_and_slide()
	update_animations()

func update_animations():
	if velocity.x > 0:
		$AnimatedSprite2D.scale.x = 4
	elif velocity.x < 0:
		$AnimatedSprite2D.scale.x = -4
		
	if is_on_floor():
		if abs(velocity.x) > 0:
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("jump")


func _on_hurt_box_body_entered(body: Node2D) -> void:
	if player_life < 0: 
		queue_free()
	else: 
		if $Ray_Right.is_colliding():
			take_demage(Vector2(-200,-200))
		elif $Ray_Left.is_colliding():
			take_demage(Vector2(200,-200))
		
		
func follow_camera(camera):
	var camera_path = camera.get_path()
	remote_transform.remote_path = camera_path
	
func take_demage(knockback_force := Vector2.ZERO, duration := 0.25):
	player_life -= 1
	
	if knockback_force != Vector2.ZERO:
		knockback_vector = knockback_force
		
		var knockback_tween := get_tree().create_tween()
		knockback_tween.parallel().tween_property(self, "knockback_vector", Vector2.ZERO, duration)
		$AnimatedSprite2D.modulate = Color(1,0,0,1)
		knockback_tween.parallel().tween_property($AnimatedSprite2D, "modulate", Color(1,1,1), duration)
		
