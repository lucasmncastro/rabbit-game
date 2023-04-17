extends Node2D

@export var initial_speed =  400
@export var cactus_1_scene: PackedScene
@export var cactus_2_scene: PackedScene
@export var cactus_3_scene: PackedScene
@export var bird_scene: PackedScene
@export var sand_scene: PackedScene

var score = 0;
var hi = 0;
var speed = 0
var gameover = false
var can_restart = true
var blinking_score = false
var blinking_score_count = 0
var blinking_score_times = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if gameover and can_restart and Input.is_action_just_released("ui_accept"):
		start();

func create_enemy():
	var scenes = [cactus_1_scene, cactus_2_scene, cactus_3_scene]
	
	# Solta os pássaros a partir dos 400 pontos.
	if score >= 400:
		scenes.append(bird_scene)

	var index = (randi() % scenes.size());
	var scene = scenes[index]
	var enemy = scene.instantiate()
	if scene == bird_scene:
		var positions = [$BirdPosition, $BirdPosition2, $BirdPosition3]
		enemy.position = positions[randi() % positions.size()].position
	else:
		enemy.position = $CactusPosition.position

	add_child(enemy);
	
# Called when the node enters the scene tree for the first time.
func _ready():
	gameover = true
	$Character.alive = false

func start():
	gameover = false;
	$EnemyTimer.start();
	$Character/AnimatedSprite2D.play()
	$ScoreTimer.start();
	$SandTimer.start();
	$GameOver.hide();
	get_tree().call_group("things", "queue_free")
	
	score = 0
	$Character.alive = true;
	
	speed = initial_speed;
	$Character.jump_velocity = -600;
	$Character.gravity = 2000;

func _on_character_hit():
	$HitAudioStreamPlayer2D.play()
	$EnemyTimer.stop();
	$ScoreTimer.stop();
	$SandTimer.stop();
	$Character/AnimatedSprite2D.stop();
	$GameOver.show();
	$RestartTimer.start();
	can_restart = false
	if (score > hi):
		hi = score;
		$HiScore.text = "%06d" % hi;
	speed = 0;
	gameover = true;

func _on_enemy_timer_timeout():
	var should_show = ((randi() % 3) == 1);
	if not should_show:
		create_enemy();

func update_score():
	if not blinking_score:
		$Score.text = "%06d" % score;

func update_speed():
	if (speed < 1000) and (score % 100 == 0):
		speed += 100

func blink_important_score():
	if (score % 100 == 0):
		blinking_score = true
		$ScoreAudioStreamPlayer2D.play()
		$BlinkScoreTimer.start();

func _on_score_timer_timeout():
	score += 1
	update_score();
	blink_important_score();
	update_speed();

func _on_sand_timer_timeout():
	var sand = sand_scene.instantiate()
	sand.position = $CactusPosition.position
	
	# Afasta um pouco pra baixo da linha do cactus.
	sand.position.y += 40

	sand.frame = (randi() % 3)
	add_child(sand)

func _on_restart_timer_timeout():
	can_restart = true

func _on_blink_timer_timeout():
	if $GameOver/Message.visible:
		$GameOver/Message.hide()
	else:
		$GameOver/Message.show()

func _on_blink_score_timer_timeout():
	if blinking_score:
		$Score.visible = not $Score.visible

	if blinking_score_count < blinking_score_times:
		blinking_score_count += 1 
	else:
		$Score.visible = true
		blinking_score = false
		blinking_score_count = 0
		$BlinkScoreTimer.stop()
