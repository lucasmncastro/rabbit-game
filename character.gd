extends CharacterBody2D

@export var alive         = true
@export var jump_velocity = -400.0
@export var gravity       = 900

signal hit;

func _physics_process(delta):
	# Retorna se tiver morto, assim ele não se move, fica paradão.
	if not alive:
		return
		
	# Add the gravity.		
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		$JumpAudioStreamPlayer2D.play()
		
	if is_on_floor():
		if Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("running_down")
			$Area2D/CollisionUp.disabled = true
			$Area2D/CollisionDown.disabled = false
		else:
			$AnimatedSprite2D.play("running")
			$Area2D/CollisionUp.disabled = false
			$Area2D/CollisionDown.disabled = true
	else:
		$AnimatedSprite2D.play("jumping")

	move_and_slide()

func _on_area_2d_area_entered(_area):
	alive = false;	
	hit.emit();
