extends Node

class_name Panneau

static func spawn_panneau(panneau_name, panneau_position, ground_height):
    
    var new_panneau_scene := preload("res://scenes/panneau.tscn")
    var new_panneau := new_panneau_scene.instantiate()
    new_panneau.texture = load("res://Assets/panneaux_tuto/" + panneau_name + ".png")
    new_panneau.position.x = panneau_position
    new_panneau.position.y = ground_height - new_panneau.texture.get_height()/2
    return new_panneau
