extends Node

var taupe_scene = preload("res://scenes/taupe.tscn")
var branche_scene = preload("res://scenes/branche.tscn")
var photo_scene = preload("res://scenes/photo.tscn")

var obstacle_types := [taupe_scene, branche_scene, photo_scene]
var obstacles : Array

var panneaux_tuto_textures := ["welcome_1", "welcome_2", "welcome_3", "moles", "branches", "picture", "good_luck"]
var panneaux_tuto_positions := [2000, 3000, 4000, 5000, 7000, 9000, 11000]

const JIM_START_POS := Vector2i(498, 330)
const CAM_START_POS := Vector2i(576, 324)
const START_SPEED : float = 4
const SPEED_INCREASE_FACTOR = 0.2
const MAX_SPEED : float = 20

var screen_size : Vector2i
var speed : float
var ground_height : int
var last_obs
var score : int

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_window().size
    ground_height = $Ground.get_node("Sprite2D").texture.get_height()
    new_game()

func new_game():
    
    score = 0
    
    $Character.position = JIM_START_POS
    $Character.velocity = Vector2i(0, 0)
    $Camera2D.position = CAM_START_POS
    $Ground.position = Vector2i(0, 548)

    
    for obs in obstacles:
        obs.queue_free()
    obstacles.clear()
    
    for i_panneau in range(len(panneaux_tuto_positions)):
        var new_panneau_scene := preload("res://scenes/panneau.tscn")
        var new_panneau := new_panneau_scene.instantiate()
        new_panneau.texture = load("res://Assets/panneaux_tuto/" + panneaux_tuto_textures[i_panneau] + ".png")
        new_panneau.position.x = panneaux_tuto_positions[i_panneau]
        new_panneau.position.y = screen_size.y - ground_height - new_panneau.texture.get_height()/2
        add_child(new_panneau)
    
    var obs_pos = 6000
    for obs_init in obstacle_types:
        var cur_obs = obs_init.instantiate()
        var obs_height = cur_obs.get_node("Sprite2D").texture.get_height()
        var obs_scale = cur_obs.get_node("Sprite2D").scale
        obs_height = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) - cur_obs.height
        add_obs(cur_obs, obs_pos, obs_height)
        last_obs = cur_obs
        obs_pos += 2000

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
        
    $Character.position.x += speed
    speed = min(START_SPEED + (score*SPEED_INCREASE_FACTOR), MAX_SPEED)
    $Camera2D.position.x += speed
    
    if $Character.position.x > 12000:
        
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
        elif $Character.position.x > 12000 and $Character.position.x < 12500:
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
        var obs_type = obstacle_types[randi() % obstacle_types.size()]
        var obs
        obs = obs_type.instantiate()
        var obs_height = obs.get_node("Sprite2D").texture.get_height()
        var obs_scale = obs.get_node("Sprite2D").scale
        var obs_x : int = screen_size.x + $Character.position.x + dist_char
        var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) - obs.height
        last_obs = obs
        add_obs(obs, obs_x, obs_y)

func add_obs(obs, x, y):
    obs.position = Vector2i(x, y)
#    obs.body_entered.connect(hit_obs)
    add_child(obs)
    obstacles.append(obs)

func remove_obs(obs):
    obs.queue_free()
    obstacles.erase(obs)
