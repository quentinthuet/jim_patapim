extends CharacterBody2D

signal hit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var must_maintain = false

func _physics_process(delta):
    # Add the gravity.
    if not is_on_floor():
        velocity.y += gravity * delta

    # Handle Jump.
    
    if Input.is_action_pressed("ui_down"):
        $CrouchCollisionShape2D.disabled = false
        $VerticalCollisionShape2D.disabled = true
        $AnimatedSprite2D.animation = "crouch"
    else:
        $CrouchCollisionShape2D.disabled = true
        $VerticalCollisionShape2D.disabled = false
        if (Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_up")) and is_on_floor():
            $AnimatedSprite2D.animation = "jump"
            velocity.y = JUMP_VELOCITY
        elif Input.is_action_pressed("ui_left"):
            $AnimatedSprite2D.animation = "pose"
        elif is_on_floor():
            $AnimatedSprite2D.animation = "run"
        if must_maintain and not Input.is_action_pressed("ui_left"):
            die()
        
    move_and_slide()

func die():
    hit.emit()
