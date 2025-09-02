extends Node

var taupe_scene = preload("res://scenes/taupe.tscn")
var branche_scene = preload("res://scenes/branche.tscn")
var photo_scene = preload("res://scenes/photo.tscn")

var obstacles_types := [taupe_scene, branche_scene, photo_scene]
var obstacles : Array

var panneaux_tuto_names := ["welcome_1", "welcome_2", "welcome_3", "moles", "branches", "picture", "good_luck"]
var panneaux_tuto_positions := [2000, 3000, 4000, 5000, 7000, 9000, 11000]

const JIM_START_POS := Vector2i(498, 330)
const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 6
const SPEED_INCREASE_FACTOR = 0.2
const MAX_SPEED : float = 20

var screen_size : Vector2i
var speed : float
var ground_height : int
var last_obs
var score : int

var show_tutorial : bool = false
var real_start_position : int

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_window().size
    ground_height = screen_size.y - $Ground.get_node("Sprite2D").texture.get_height()
    new_game()

func new_game():
    
    score = 0
    
    $Character.position = JIM_START_POS
    $Character.velocity = Vector2i(0, 0)
    $Camera2D.position = CAM_START_POS
    $Ground.position = Vector2i(0, 548)

    real_start_position = 12000 if show_tutorial else 0
    
    for obs in obstacles:
        obs.queue_free()
    obstacles.clear()
    
    if show_tutorial:
        for i_panneau in range(len(panneaux_tuto_positions)):
            add_child(Panneau.spawn_panneau(
                panneaux_tuto_names[i_panneau],
                panneaux_tuto_positions[i_panneau],
                ground_height
            ))
    
        var obs_pos = 6000
        for obs_init in obstacles_types:
            var cur_obs = obs_init.instantiate()
            add_obs(cur_obs, obs_pos)
            obs_pos += 2000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
        
    $Character.position.x += speed
    speed = min(START_SPEED + (score*SPEED_INCREASE_FACTOR), MAX_SPEED)
    $Camera2D.position.x += speed
    
    if $Character.position.x > real_start_position:    
        if score >= 0:
            $HUD/ScoreLabel.text = "SCORE: " + str(score)
        generate_obs()
    
    if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
        $Ground.position.x += screen_size.x

    var in_an_obs = false
    for obs in obstacles:
        if obs.position.x < ($Camera2D.position.x - screen_size.x):
            remove_obs(obs)
        if $Character.position.x > obs.position.x - 150 and $Character.position.x < obs.position.x + 50:
            $HUD/Shouting.text = obs.shout_name
            in_an_obs = true
        elif $Character.position.x > real_start_position and $Character.position.x < real_start_position + 1000:
            $HUD/Shouting.text = "GO!!"
        elif not in_an_obs:
            $HUD/Shouting.text = ""

func generate_obs():
    #generate ground obstacles
    if obstacles.is_empty() or last_obs.position.x < $Character.position.x:
        if not obstacles.is_empty():
            score += 1
            print(speed)
        var dist_char = randi_range(-50, 400)
        var obs_type = obstacles_types[randi() % obstacles_types.size()]
        var obs
        obs = obs_type.instantiate()
        add_obs(obs, screen_size.x + $Character.position.x + dist_char)

func add_obs(obs, obs_x):
    var obs_height = obs.get_node("Sprite2D").texture.get_height()
    var obs_scale = obs.get_node("Sprite2D").scale
    var obs_y : int = ground_height - (obs_height * obs_scale.y / 2) - obs.height
    last_obs = obs
    obs.position = Vector2i(obs_x, obs_y)
    add_child(obs)
    obstacles.append(obs)

func remove_obs(obs):
    obs.queue_free()
    obstacles.erase(obs)
