extends Area2D

var speed;

# Called when the node enters the scene tree for the first time.
func _ready():
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("default")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed = get_node("/root/Main").speed
	if (speed > 0):
		position.x -= speed * delta;
