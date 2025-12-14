extends Area2D

class_name Obstacle

@export var height = 0 
@export var shout_name = ""
@export var is_a_trigger_zone = false

func _ready():
    # Connexion du signal interne de l'Area2D vers la fonction du script
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
    if body.name == "Character":
        if is_a_trigger_zone:
            body.must_maintain = true
        else:
            body.die()

func _on_body_exited(body: Node2D) -> void:
    if body.name == "Character":
        if is_a_trigger_zone:
            body.must_maintain = false
